/* UART asynchronous example, that uses separate RX and TX tasks

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "driver/uart.h"
#include "string.h"
#include <stdlib.h>
#include "unity.h"

#include "cJSON.h"
#include "pwm.h"
#include "bmi2.h"
#include "initgpio.h"


//.......... I2C DEFINE  ............//

#define I2C_MASTER_SCL_IO 22      /*!< gpio number for I2C master clock */
#define I2C_MASTER_SDA_IO 21      /*!< gpio number for I2C master data  */
#define I2C_MASTER_NUM I2C_NUM_0  /*!< I2C port number for master dev */
#define I2C_MASTER_FREQ_HZ 100000 /*!< I2C master clock frequency */

#define bmi2_I2C_ADDRESS         0x68u /*!< I2C address with AD0 pin low */
#define bmi2_WHO_AM_I_VAL        0x24u

//........ PIN OUT DEFINE ..........//



//........ DESIGN FOR TEST .........//
#define PRODUCT 0						// PRODUCT == 1  OR TESTING == 0


//...........MQTT DEFINE .............//
#define BROKER "mqttserver.tk"
#define CLIENTID "TestModuleHUYGL"
#define USERNAME "innovation"
#define PASSWORD "Innovation_RgPQAZoA5N"
#define PUBTOPIC "/innovation/airmonitoring/SmartPole"
#define SUBTOPIC "/innovation/airmonitoring/SmartPole"



//// ..............GLOBAL VARIABLE..........//////////

enum STATUS_MQTT  {NOTHING = -2, ERROR = -1, ACKNOW = 0, OK = 1};
enum STATUS_MQTT ACK = NOTHING;
static int Err_count = 0;

int lumi = 0;
bool ccidflag = 0;
char ccid[30] = "NONE";

uint32_t soft_timer = 0;
bool demo_mode = 0;

// ......... BMI GLOBAL VARIABLE............//
bmi2_handle_t bmi2 = NULL;
esp_err_t ret;
uint8_t bmi2_deviceid;
bmi2_acce_value_t acce[5];
bmi2_acce_value_t acce_avg = {0,0,0};
float inclination = 0.0;
int number_of_sample = 5;






//# INIT EVERYTHING..........//////////


static void DimmingLight(int duty_cycle){
	if (duty_cycle == 0) gpio_set_level(RELAY, 0);
	else gpio_set_level(RELAY, 1);

	printf("DIMMING: %d\n", duty_cycle);
	pwm_set_duty(duty_cycle);
}



void i2c_bus_init(void)
{
    i2c_config_t conf;
    conf.mode = I2C_MODE_MASTER;
    conf.sda_io_num = (gpio_num_t)I2C_MASTER_SDA_IO;
    conf.sda_pullup_en = GPIO_PULLUP_ENABLE;
    conf.scl_io_num = (gpio_num_t)I2C_MASTER_SCL_IO;
    conf.scl_pullup_en = GPIO_PULLUP_ENABLE;
    conf.master.clk_speed = I2C_MASTER_FREQ_HZ;
    conf.clk_flags = I2C_SCLK_SRC_FLAG_FOR_NOMAL;

    esp_err_t ret = i2c_param_config(I2C_MASTER_NUM, &conf);
    TEST_ASSERT_EQUAL_MESSAGE(ESP_OK, ret, "I2C config returned error");

    ret = i2c_driver_install(I2C_MASTER_NUM, conf.mode, 0, 0, 0);
    TEST_ASSERT_EQUAL_MESSAGE(ESP_OK, ret, "I2C install returned error");
}

void bmi2_init(void)
{
    esp_err_t ret;

    i2c_bus_init();
    bmi2 = bmi2_create(I2C_MASTER_NUM, bmi2_I2C_ADDRESS);
    TEST_ASSERT_NOT_NULL_MESSAGE(bmi2, "bmi2 create returned NULL");

    ret = bmi2_begin(bmi2);
    TEST_ASSERT_EQUAL(ESP_OK, ret);


    ret = bmi2_get_deviceid(bmi2, &bmi2_deviceid);
    assert(ret == ESP_OK);
    assert(bmi2_deviceid == bmi2_WHO_AM_I_VAL);
}

void read_acceleration(void* pvParameter)
{
	get_data_to_array:for(int i=0;i<number_of_sample;i++){
		ret = bmi2_get_acce(bmi2, acce+i);
		assert(ESP_OK == ret);
		vTaskDelay(pdMS_TO_TICKS(15));				//the delay depend on sample rate, here 100Hz -> minimum delay 10ms
	}

	if(averaging_acce(acce,number_of_sample,&acce_avg) == false) goto get_data_to_array;

	inclination = bmi2_get_inclination(acce_avg.acce_z);
	printf("acce_x:%.5f, acce_y:%.5f, acce_z:%.5f\n", acce_avg.acce_x, acce_avg.acce_y, acce_avg.acce_z);
	printf("DO nghieng: %.2f*\n\n", inclination);
}





// SEND DATA via UART
int sendData(const char* logName, const char* data, uint8_t try)
{
	ACK = NOTHING;
    const int len = strlen(data);
    const int txBytes = uart_write_bytes(UART_DRIVER, data, len);
    ESP_LOGI(logName, "Wrote %d bytes", txBytes);
    ESP_LOGI(logName, "Write:  %s\n",data);

    while (try > 0){
    	if (ACK > NOTHING) break;
    	else {
    		try--;
    		vTaskDelay(1000 / portTICK_PERIOD_MS);
    	}
    }
    return ACK;
}









//**************************
// Process CENG data
//**************************
cJSON *json = NULL;
//char ceng_data[256]="";
int ceng_len = 0;

char *psi,*rsrp,*rsrq,*sinr,*cellID;
int msgID = 0;
void getDataCENG(char* rawData){
	cJSON_Delete(json);
	json = cJSON_CreateObject();


	cJSON_AddStringToObject(json, "action", "updateData");
	cJSON_AddStringToObject(json, "ccid", ccid);
	cJSON_AddStringToObject(json, "id", "streetlightLTK");
	cJSON_AddNumberToObject(json, "msgid", msgID++);
	cJSON_AddNumberToObject(json, "lumi", lumi);

	char accel_str[20];

	sprintf(accel_str, "%.2f", inclination);
	cJSON_AddStringToObject(json, "incli", accel_str);
	sprintf(accel_str, "%.3f", acce_avg.acce_x);
	cJSON_AddStringToObject(json, "x", accel_str);
	sprintf(accel_str, "%.3f", acce_avg.acce_y);
	cJSON_AddStringToObject(json, "y", accel_str);
	sprintf(accel_str, "%.3f", acce_avg.acce_z);
	cJSON_AddStringToObject(json, "z", accel_str);


	int count2 = 2;
	if(rawData == NULL)
		return;
    char* data = strstr(rawData,"\"");

    char arrData[strlen(data)];
    for(int i = 0;i < strlen(data);i++){
        arrData[i] = data[i];
    }
    char* presentData = strtok(arrData," \",");
    while(presentData != NULL && count2 <9){
        presentData = strtok(NULL, " ,");


        if(count2 == 3){
        	cJSON_AddNumberToObject(json, "rsrp", atoi(presentData));
        }
        else if(count2 ==8){
        	cJSON_AddNumberToObject(json, "cellID", atoi(presentData));
        }
        count2++;
    }

    count2 = 2;

}


//**************************
// Process GNSS data
//**************************

char *date,*longitude,*latitude;
void getDataCGNSINF(char* rawData){
	int count3 = 1;

	if(rawData == NULL)
		return;
	char* data = strstr(rawData,",");
	char arrData[strlen(data)];
	for(int i = 0;i < strlen(data);i++){
		arrData[i] = data[i];
	}
	char* presentData = strtok(arrData,",");
	cJSON_AddStringToObject(json, "date", presentData);

	while(presentData != NULL && count3 <9){
	        presentData = strtok(NULL, ",");
	        if(count3 == 1){
	        	cJSON_AddNumberToObject(json, "latitude", strtod(presentData,NULL));
	        }
	        else if(count3 == 2){
	        	cJSON_AddNumberToObject(json, "longitude", strtod(presentData,NULL));
	        }
	        count3++;
	    }
	count3 = 1;
}










//**********************************
// MQTT TASK
//**********************************

static int status_mqtt = 0;
static void mqtt_task(void *arg)
{

	char *json_str = NULL;

    static const char *MQTT_TASK_TAG = "MQTT_TASK";
    esp_log_level_set(MQTT_TASK_TAG, ESP_LOG_INFO);
    while (1) {

    	//TODO Check connect
    	if (status_mqtt == 0){

    		sendData(MQTT_TASK_TAG, "AT+CEREG=0\r",4);
    		vTaskDelay(500 / portTICK_PERIOD_MS);

    		ccidflag=1;
    		sendData(MQTT_TASK_TAG, "AT+CCID\r",4);
    		vTaskDelay(1000 / portTICK_PERIOD_MS);


    		for (int i = 0; i < 10; i++){
    			if ( sendData(MQTT_TASK_TAG, "AT+CEREG?\r",5)  == OK  ){
    			    break;
    			}
    			else vTaskDelay(500 / portTICK_PERIOD_MS);
    		}
    		if ( sendData(MQTT_TASK_TAG, "AT+CEREG?\r",2)  != OK  ) esp_restart();


    		vTaskDelay(500 / portTICK_PERIOD_MS);
    		sendData(MQTT_TASK_TAG, "AT+CNACT=0,1\r", 15);

    		status_mqtt = 1;
    		vTaskDelay(500 / portTICK_PERIOD_MS);
    	}



    	// .............. CONFIGH Host and client ID ......................//
    	else if (status_mqtt == 1){

    		char config_mqtt[100];

//    		sprintf(config_mqtt,"AT+SMCONF=\"URL\",\"%s\"\r", BROKER);
    		sendData(MQTT_TASK_TAG, config_mqtt, 3);
    		vTaskDelay(200 / portTICK_PERIOD_MS);

//    		sprintf(config_mqtt,"AT+SMCONF=\"CLIENTID\",\"%s\"\r", CLIENTID);
    		sendData(MQTT_TASK_TAG, config_mqtt,3);
    		vTaskDelay(200 / portTICK_PERIOD_MS);

//    		sprintf(config_mqtt,"AT+SMCONF=\"USERNAME\",\"%s\"\r", USERNAME);
    		sendData(MQTT_TASK_TAG, config_mqtt ,3);
			vTaskDelay(200 / portTICK_PERIOD_MS);

//			sprintf(config_mqtt,"AT+SMCONF=\"PASSWORD\",\"%s\"\r", PASSWORD);
			sendData(MQTT_TASK_TAG, config_mqtt ,3);
			vTaskDelay(200 / portTICK_PERIOD_MS);


			sendData(MQTT_TASK_TAG, "AT+SMCONF=\"KEEPTIME\",\"6000\"\r",3);
			vTaskDelay(200 / portTICK_PERIOD_MS);

			sendData(MQTT_TASK_TAG, "AT+SMCONF?\r",3);
    		status_mqtt = 2;
    		vTaskDelay(500 / portTICK_PERIOD_MS);
    	}



    	// CONNECTING.....
    	else if (status_mqtt == 2){
    		sendData(MQTT_TASK_TAG, "AT+SMCONN\r", 15);

    	    if (ACK == OK) status_mqtt = 4;
    	}


    	//Subscribe
    	else if (status_mqtt == 4){
    		led_status = 2;
    		char config_mqtt[100];

//    		sprintf(config_mqtt,"AT+SMUNSUB=\"%s\"\r\n", SUBTOPIC);
    		sendData(MQTT_TASK_TAG, config_mqtt ,3);
    		vTaskDelay(300 / portTICK_PERIOD_MS);

//    		sprintf(config_mqtt,"AT+SMSUB=\"%s\",1\r\n", SUBTOPIC);
    		sendData(MQTT_TASK_TAG, config_mqtt ,3);
    		status_mqtt = 5;

    		vTaskDelay(300 / portTICK_PERIOD_MS);
    	}


   //*********************************************//
   //**************** MAIN LOOP ******************//
   //*********************************************//

    	//Get +CENG DATA
    	else if (status_mqtt == 5){


    		if (PRODUCT) read_acceleration(NULL);					// Doc do nghieng

    		sendData(MQTT_TASK_TAG, "AT+CENG?\r",10);
    		vTaskDelay(1000 / portTICK_PERIOD_MS);
    		if (ACK == OK) status_mqtt = 7;
    	}


    	// Publishing.......
    	// Format-------------------
    	// AT+SMPUB="messages/d86dabaa-d818-4e30-b7ee-fa649f772bda/update",64,0,1
    	// -------------------------
        else if (status_mqtt == 7){

        	char msg[100];

        	json_str = cJSON_PrintUnformatted(json);
        	ceng_len = strlen(json_str);
        	//strcpy(ceng_data, json_str);

//        	sprintf(msg,"AT+SMPUB=\"%s\",%d,0,1\r", PUBTOPIC ,ceng_len);
        	sendData(MQTT_TASK_TAG, msg,3);
   	   		vTaskDelay(1000 / portTICK_PERIOD_MS);
   	   		status_mqtt = 8;
   	   	}


    	//Adding data publish..... and DONE
        else if (status_mqtt == 8){
           	sendData(MQTT_TASK_TAG, json_str,3);
            cJSON_free(json_str);
           	status_mqtt = 5;
           	vTaskDelay(55000 / portTICK_PERIOD_MS);
        }
    }
}




int run_counter = 0;
static void prepare_task(void *arg)
{
    static const char *TX_TASK_TAG = "TX_TASK";
    esp_log_level_set(TX_TASK_TAG, ESP_LOG_INFO);
    while (1) {
    	printf("At preparing step:.. %d\n",run_counter);


    	//*************  USED FOR TURN OFF MODULE ************//
    	//TODO Turn off anyway at the first state
    	if (run_counter == -3){
    		sendData(TX_TASK_TAG, "at+cpowd=0\r",3);
    		vTaskDelay(1000 / portTICK_PERIOD_MS);
    		run_counter = -2;
    		vTaskDelay(3000 / portTICK_PERIOD_MS);
    	}

    	// Turn on 1 ---> hold 1 in 5s
    	else if (run_counter == -2){
    		gpio_set_level(POWER,0);
    		run_counter = -1;
    		vTaskDelay(5000 / portTICK_PERIOD_MS);
    	}
    	// release 0 and wait 5s for completely setup
    	else if (run_counter == -1){
    		gpio_set_level(POWER,1);
    		run_counter = 0;
    		vTaskDelay(10000 / portTICK_PERIOD_MS);
    	}





    	//****------- MAIN PREPARATION HERE  --------****//

    	// Re-call turn off echo until SIM accepting UART
    	else if (run_counter == 0){
    		for (int i = 0; i < 7; i++){
    			sendData(TX_TASK_TAG, "ate0\r",1);
    		}
    		if (ACK == OK) run_counter = 1;
    	}
    	else if (run_counter == 1){

    		gpio_set_level(RELAY, 1);
    		vTaskDelay(1000 / portTICK_PERIOD_MS);
    		gpio_set_level(RELAY, 0);

    		sendData(TX_TASK_TAG, "at\r\n",3);
    	    vTaskDelay(300 / portTICK_PERIOD_MS);
    	    sendData(TX_TASK_TAG, "AT+SMDISC\r\n",3);
    	    vTaskDelay(300 / portTICK_PERIOD_MS);
    	    sendData(TX_TASK_TAG, "AT+CNACT=0,0\r\n",3);
    	    vTaskDelay(300 / portTICK_PERIOD_MS);
    	    led_status = 1;
//    	    demo_mode = 1;

    	    xTaskCreate(mqtt_task, "mqtt_task", 3200, NULL, configMAX_PRIORITIES-2, NULL);
    	    vTaskDelete(NULL);
    	    break;
    	}
    }
}







static void rx_task(void *arg)
{
    static const char *RX_TASK_TAG = "RX_TASK";
    esp_log_level_set(RX_TASK_TAG, ESP_LOG_INFO);
    uint8_t* data = (uint8_t*) malloc(RX_BUF_SIZE+1);
    while (1) {
        const int rxBytes = uart_read_bytes(UART_DRIVER, data, RX_BUF_SIZE, 1000 / portTICK_PERIOD_MS);
        if (rxBytes > 0) {
            data[rxBytes] = 0;

            char* temp = (char*)data;


            ACK = ACKNOW;
            // Get CENG Info


            if (ccidflag){
            	ccidflag = 0;
            	strncpy(ccid, temp+2, 20);
            	ccid[20] = '\0';
            	run_counter += 1;
            	ACK = OK;
            }

            else if (strstr(temp,"+CENG")){

               if (rxBytes < 55) {
            	   ESP_LOG_BUFFER_HEXDUMP(RX_TASK_TAG, data, rxBytes, ESP_LOG_ERROR);
            	   ACK = ERROR;
               }
               else{
            	   getDataCENG((char*)data);
            	   run_counter += 1;
            	   ACK = OK;
//            	   printf("Count: %d\n",run_counter);
               }
            }


            else if (strstr(temp, "+CEREG: 0")){
            	char temp_str[5];
            	strncpy(temp_str, temp + 12 , 1);
            	temp_str[1] = '\0';

            	int cereg = atoi(temp_str);
            	if (cereg == 1) ACK = OK;
            	else ACK = NOTHING;

            }




            // Process ERROR , EXCEPTION
            else if (strstr(temp,"OK")) {
            	ACK = OK;
            	run_counter += 1;
//            	printf("Count: %d\n",run_counter);
            }

            else if (strstr(temp,"ERROR")){
            	ACK = ERROR;
            	ESP_LOG_BUFFER_HEXDUMP(RX_TASK_TAG, data, rxBytes, ESP_LOG_ERROR);
            }


            // PROCESS DIMMING SIGNAL
            // +SMSUB: "jackwrion12345/feeds/dimming","22"
            // +SMSUB: "AI_ProjectHGL/feeds/pole","22"
            // +SMSUB: "/innovation/airmonitoring/SmartPole","{"station_id":"air_0002","station_name":"NBIOT 0002","action":"control light","device_id":"streetlightLTK","data":"46"}"
            char* idx = strstr(temp,"+SMSUB");
            if (idx) {
                char* json_str_start = strchr(idx, '{');  // Find the start of the JSON payload
                if (json_str_start) {
                    char* json_str_end = strchr(json_str_start, '}');  // Find the end of the JSON payload
                    if (json_str_end && json_str_end > json_str_start) {
                        int json_length = json_str_end - json_str_start + 1;
                        char json_str[json_length + 1];  // Buffer to hold the JSON string
                        strncpy(json_str, json_str_start, json_length);
                        json_str[json_length] = '\0';  // Null-terminate the JSON string

                        cJSON *json = cJSON_Parse(json_str);  // Parse the JSON string
                        if (json) {
                            const cJSON *action = cJSON_GetObjectItem(json, "action");
                            const cJSON *device_id = cJSON_GetObjectItem(json, "device_id");
                            const cJSON *data = cJSON_GetObjectItem(json, "data");

                            // Check if action and device_id are as expected
                            if (cJSON_IsString(action) && cJSON_IsString(device_id) &&
                                strcmp(action->valuestring, "control light") == 0 &&
                                strcmp(device_id->valuestring, "streetlightLTK") == 0) {

                                // Convert data to integer
                                int duty_cycle = data ? atoi(data->valuestring) : 0;

                                // Process duty_cycle
                                if (duty_cycle == 200) {  // TUNR-ON DEMO MODE
                                    demo_mode = 1;
                                    printf("DEMO_MODE_ON");
                                } else if (duty_cycle == 99) {  // TUNR-OFF DEMO, BACK TO PREVIOUS DIMMING
                                    demo_mode = 0;
                                    duty_cycle = lumi;
                                } else {  // MANUALLY DIMMING
                                    demo_mode = 0;
                                    lumi = duty_cycle;
                                }
                                DimmingLight(duty_cycle);
                            }

                            cJSON_Delete(json);  // Free the JSON object
                        }
                    }
                }
            }


            // handler when Error too much
            if (ACK == ERROR){
            	Err_count += 1;
            	if (Err_count == 10) esp_restart();
            }
            else Err_count = 0;


            ESP_LOGI(RX_TASK_TAG, "Read %d bytes:...\n", rxBytes);
            ESP_LOG_BUFFER_HEXDUMP(RX_TASK_TAG, data, rxBytes, ESP_LOG_WARN);
        }
    }
    free(data);
}









void led_task(void * arg){
	int toggle = 0;
	int light = 0;
	while (1){

		// LED STATUS FOR PROPERLY WORKING
		if (led_status == 0){
			gpio_set_level(2,0);
		}
		else if (led_status == 1){
			gpio_set_level(2,1);
		}
		else {
			toggle = 1-toggle;
			gpio_set_level(2,toggle);
		}


		// FOR DEMO:  DIMMING FROM 0 to 100 in 10 seconds.
		if (demo_mode == 1){
			if (soft_timer % 2 == 0){
				light += 20;
				if (light > 100) light = 0;
			}
			lumi = light;
			DimmingLight(light);
		}

		soft_timer++;
		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}
}





void app_main(void)
{
    uart_init(PRODUCT);
    power_init();
	pwm_init();
    led_init();
    relay_init();

    if (PRODUCT) bmi2_init();


    xTaskCreate(rx_task, "uart_rx_task", 1024*2, NULL, configMAX_PRIORITIES, NULL);
    xTaskCreate(prepare_task, "uart_tx_task", 3200, NULL, configMAX_PRIORITIES-3, NULL);
    xTaskCreate(led_task, "LED_task", 1024, NULL, configMAX_PRIORITIES-2, NULL);
}
