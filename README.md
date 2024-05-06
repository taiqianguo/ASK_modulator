# ASK_modulator
design a ASK modulator using DDS

digital modulator
Quartus13.0+modelsim10.7
Verilog
content:
Using the FPGA chip as the core chip, a digital modulation baseband signal is generated internally. The modulation symbols can be set through an external DIP switch. The baseband signal is converted into a multi-level parallel code through a serial-to-parallel conversion circuit, and the carrier is keyed through keying. Make adjustments. Note: Use the ROM inside the FPGA to store a sine list parameter, read the sine parameters through a table lookup method to generate a sine carrier signal, write a DDS control module program, and achieve any frequency setting within the frequency range; construct a ROM sine list, address The depth can be defined according to actual needs. After digital modulation, it is sent to an external DAC for digital-to-analog conversion, and finally converted into an analog signal output. Require:
Modulation mode: 2ASK, 4ASK, 8ASK (can be set), symbol rate: 10Kbit/s, carrier frequency: 1MHz, output amplitude: 2Vpp.

Module:
1. Binary pseudo-random number generator, rate 10kbit/s.
2. rom with 200 LUT(look up table)
3. lut.py is the script to generate sin look up atbel data.
   
  <img width="276" alt="image" src="https://github.com/taiqianguo/ASK_modulator/assets/58079218/c5369be8-5cc5-42fa-b379-5011ebbdd03e">

  
3. Data_converter includes serial data conversion to parallel and digital modulation.
4. ASK_mudulator is the top mudule, connected in series with other modules, and includes verilog blocks such as key detection and output amplitude attenuation.
5.DDS


  <img width="292" alt="image" src="https://github.com/taiqianguo/ASK_modulator/assets/58079218/7b2c2d05-3525-4ea1-8f1a-aeff48ef43c0">

  
6. signal ports: button1 S9, button0 S8, reset R10
7. Operation method: After pressing reset, press the button twice in succession, press s9, s8 is 01, 2ask. Press s8, s9 is 10, 4ask. Press s9s9, it is 11, 8ask. Press s8, s8 is 00, no output, you need to press reset again before setting.
8. Three buttons have been added. One is to switch the input mode. Press once to switch to key input, and press again to switch to random input. Then during key input, pressing button2 is 0, pressing button3 is 1, and the output is based on the ask mode. For example, in 4ASK mode, pressing button2/3 twice will output one value, and pressing button2/3 twice will output another value.
9. dac out put as:

   
   <img width="306" alt="image" src="https://github.com/taiqianguo/ASK_modulator/assets/58079218/15beb3e9-c22a-4353-a8ec-c0a67cc68495">



Details can be referred in the comment of the code.


simulation results:

4ASK:


<img width="2000" alt="image" src="https://github.com/taiqianguo/ASK_modulator/assets/58079218/71f5a203-6d60-4a2c-9434-734828ca18d0">


<img width="2000" alt="image" src="https://github.com/taiqianguo/ASK_modulator/assets/58079218/8b4cbb07-7f5b-4ae5-99f3-14bc093fbfb4">


8ASK:


<img width="2000" alt="image" src="https://github.com/taiqianguo/ASK_modulator/assets/58079218/8ed85e92-2c15-4fcf-945c-5acd48ffe6eb">

button switch mode:


<img width="700" alt="image" src="https://github.com/taiqianguo/ASK_modulator/assets/58079218/3e402867-c8e8-4ff4-8822-5d40ffa34c6f">
<img width="400" alt="image" src="https://github.com/taiqianguo/ASK_modulator/assets/58079218/a3ee89a8-13a3-4d34-a5e9-f97553ef8468">
