import argparse
import cv2
import os
import numpy as np
from pycoral.adapters.common import input_size
from pycoral.adapters.detect import get_objects
from pycoral.utils.dataset import read_label_file
from pycoral.utils.edgetpu import make_interpreter, run_inference
from tracker import ObjectTracker
import time

# Config value
SOURCE = np.array([[648, 233], [1443, 218], [1222, 28], [838, 33]])
TARGET_WIDTH = 16
TARGET_HEIGHT = 20
TARGET = np.array(
    [
        [0, 0],
        [TARGET_WIDTH - 1, 0],
        [TARGET_WIDTH - 1, TARGET_HEIGHT - 1],
        [0, TARGET_HEIGHT - 1],
    ]
)

class ViewTransformer:
    def __init__(self, source: np.ndarray, target: np.ndarray) -> None:
        source = source.astype(np.float32)
        target = target.astype(np.float32)
        self.m = cv2.getPerspectiveTransform(source, target)

    def transform_points(self, points: np.ndarray) -> np.ndarray:
        if points.size == 0:
            return points

        reshaped_points = points.reshape(-1, 1, 2).astype(np.float32)
        transformed_points = cv2.perspectiveTransform(reshaped_points, self.m)
        return transformed_points.reshape(-1, 2)

def append_objs_to_img(cv2_im, inference_size, objs, labels, tracker, view_transformer, previous_positions, previous_times):
    height, width, channels = cv2_im.shape
    scale_x, scale_y = width / inference_size[0], height / inference_size[1]
    current_time = time.time()

    detect = []
    for obj in objs:
        bbox = obj.bbox.scale(scale_x, scale_y)
        x0, y0 = int(bbox.xmin), int(bbox.ymin)
        x1, y1 = int(bbox.xmax), int(bbox.ymax)
        percent = int(100 * obj.score)
        label = '{}% {}'.format(percent, labels.get(obj.id, obj.id))
        cv2_im = cv2.rectangle(cv2_im, (x0, y0), (x1, y1), (0, 255, 0), 2)
        cv2_im = cv2.putText(cv2_im, label, (x0, y0 + 30), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (255, 0, 0), 2)
        detect.append([x0, y0, x1, y1, obj.score])

    tracks = tracker.update(np.array(detect))

    for track in tracks:
        track_id = int(track[4])
        x0, y0, x1, y1 = map(int, track[:4])
        color = (0, 255, 0)
        label = "ID: {}".format(track_id)
        cv2.rectangle(cv2_im, (x0, y0), (x1, y1), color, 2)
        cv2.putText(cv2_im, label, (x0, y0 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

        current_position = ((x0 + x1) // 2, (y0 + y1) // 2)
        transformed_position = view_transformer.transform_points(np.array([current_position]))[0]

        if track_id in previous_positions:
            previous_position = previous_positions[track_id]
            previous_time = previous_times[track_id]
            distance = np.linalg.norm(np.array(transformed_position) - np.array(previous_position))
            time_diff = current_time - previous_time
            speed = distance / time_diff if time_diff > 0 else 0
            speed_kmh = speed * 3.6  # convert m/s to km/h
            cv2.putText(cv2_im, f"Speed: {speed_kmh:.2f} km/h", (x0 + 5, y1 + 15), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)

        previous_positions[track_id] = transformed_position
        previous_times[track_id] = current_time

    return cv2_im

def main():
    default_model_dir = '../all_models'
    default_model = 'mobilenet_ssd_v2_coco_quant_postprocess_edgetpu.tflite'
    default_labels = 'coco_labels.txt'
    parser = argparse.ArgumentParser()
    parser.add_argument('--model', help='.tflite model path',
                        default=os.path.join(default_model_dir, default_model))
    parser.add_argument('--labels', help='label file path',
                        default=os.path.join(default_model_dir, default_labels))
    parser.add_argument('--top_k', type=int, default=3,
                        help='number of categories with highest score to display')
    parser.add_argument('--camera_idx', type=int, help='Index of which video source to use.', default=0)
    parser.add_argument('--threshold', type=float, default=0.1,
                        help='classifier score threshold')
    parser.add_argument('--video', help='Path to the video file', default=None)
    parser.add_argument('--tracker', help='Name of the Object Tracker To be used.',
                        default='sort', choices=['sort'])
    args = parser.parse_args()

    print('Loading {} with {} labels.'.format(args.model, args.labels))
    interpreter = make_interpreter(args.model)
    interpreter.allocate_tensors()
    labels = read_label_file(args.labels)
    inference_size = input_size(interpreter)

    if args.video:
        cap = cv2.VideoCapture(args.video)
    else:
        cap = cv2.VideoCapture(args.camera_idx)

    tracker = ObjectTracker(args.tracker).trackerObject
    view_transformer = ViewTransformer(SOURCE, TARGET)
    previous_positions = {}
    previous_times = {}

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        cv2_im = frame

        cv2_im_rgb = cv2.cvtColor(cv2_im, cv2.COLOR_BGR2RGB)
        cv2_im_rgb = cv2.resize(cv2_im_rgb, inference_size)
        run_inference(interpreter, cv2_im_rgb.tobytes())
        objs = get_objects(interpreter, args.threshold)[:args.top_k]
        cv2_im = append_objs_to_img(cv2_im, inference_size, objs, labels, tracker, view_transformer, previous_positions, previous_times)

        cv2.imshow('frame', cv2_im)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == '__main__':
    main()

