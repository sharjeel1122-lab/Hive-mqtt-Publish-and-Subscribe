import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

String recieve = '';
class MqttClientWrapper {
  MqttServerClient? client;


  Future<void> connect() async {
    client = MqttServerClient('0f84faf18b2d426b9e777d4d7487166b.s2.eu.hivemq.cloud', '0f84faf18b2d426b9e777d4d7487166b');
    client!.port = 8883; // If using secure connection
    client!.secure = true; // If using secure connection
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('0f84faf18b2d426b9e777d4d7487166b')
        .startClean() // Start with a clean session
        .withWillTopic('Message')
        .withWillMessage('Hello MQTT')
        .withWillQos(MqttQos.atLeastOnce)
        .authenticateAs('sharjeel1', 'Qwerty007');
    client!.connectionMessage = connMess;
    try {
      await client!.connect();
    } catch (e) {
      print('Exception: $e');
      client!.disconnect();
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      print('Connected to the broker!');
    } else {
      print('Failed to connect to the broker.');
    }
  }

  void publish(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    print(message);
  }

  void subscribe(String topic) {
    client!.subscribe(topic, MqttQos.atMostOnce);
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final MqttPublishMessage receivedMessage = messages[0].payload as MqttPublishMessage;
      final String message = MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
      print('Received message: $message');
      recieve = message;
      print(recieve);
    });
  }

}

class MyWidget extends StatelessWidget {

  final MqttClientWrapper mqttClientWrapper = MqttClientWrapper();



  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('HiveMQ Cloud Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await mqttClientWrapper.connect();
                },
                child: Text('Connect to MQTT Broker'),
              ),
              ElevatedButton(
                onPressed: () {
                  mqttClientWrapper.publish('Message', '1');
                },
                child: Text('ON'),
              ),
              ElevatedButton(
                onPressed: () {
                  mqttClientWrapper.publish('Message', '0');
                },
                child: Text('OFF'),
              ),
              ElevatedButton(
                onPressed: () {
                  mqttClientWrapper.subscribe('$recieve');
                },
                child: Text('Subscribe Message'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
