import yt_dlp
import vlc
import time

# Đường dẫn đến video YouTube
url = 'https://youtube.com/live/uUaNEJBOM_8?feature=share'

# Tùy chọn tải
ydl_opts = {
    'format': 'best',  # Chọn định dạng tốt nhất
}

# Sử dụng yt-dlp để lấy thông tin stream
with yt_dlp.YoutubeDL(ydl_opts) as ydl:
    info_dict = ydl.extract_info(url, download=False)
    video_url = info_dict['url']
    print("Stream URL:", video_url)

# Khởi tạo VLC player
player = vlc.MediaPlayer(video_url)

# Phát video
player.play()

# Chờ một chút để đảm bảo video bắt đầu phát
time.sleep(5)  # Chờ 5 giây, điều chỉnh nếu cần thiết

# Chuyển sang chế độ toàn màn hình
player.set_fullscreen(True)

# Giữ chương trình chạy cho đến khi người dùng đóng trình phát
try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    # Thoát chương trình khi nhận tín hiệu từ bàn phím (Ctrl+C)
    print("Exiting...")
finally:
    # Dừng và thoát trình phát VLC
    player.stop()
    player.release()
