**ℹNote: When the webpage is opened for the first time, it will request location permissions. This is because the site needs your location to calculate satellite pass predictions.**

### 1. Interface
(1) **ZH/EN**: Switch interface language.

(2) **CODE**: View source code.

(3) **STATISTICS**: View access statistics.

(4) **Show favorites**: Calculate pass information for favorited satellites.

(5) **Show selected**: Calculate pass information for currently selected satellites.

<img width="352" height="78" alt="image" src="https://github.com/user-attachments/assets/f2603420-34bb-429a-ab05-9dd2f94bcc30" />


### 2. Satellite Pass Prediction

(1) Enter a satellite keyword in the **search box**, then click a search result to select a satellite for pass prediction.

<img width="451" height="187" alt="image" src="https://github.com/user-attachments/assets/550efd46-3d20-429b-95e8-4f6a4d9a13f3" />


(2) **Optional**: Select the number of days to predict, the minimum elevation angle, and whether to only show passes between 19:00 and 23:59.

<img width="280" height="27" alt="image" src="https://github.com/user-attachments/assets/62304ba8-9eb0-45c5-94d7-6fc58003afba" />


(3) **Optional**: Click the circle icon next to the search box to favorite the satellite.

<img width="438" height="55" alt="image" src="https://github.com/user-attachments/assets/81f87142-ebb2-4dd2-84ee-95fcc82c9d11" />


(4) Click “**Show favorites**” or “**Show selected**” to calculate passes for favorited or selected satellites.


(5) The calculation results will appear below, including date, start and end times, pass trajectory preview, and maximum elevation.(Blue and black backgrounds indicate daytime and nighttime passes, respectively. If the background is green, it indicates that the satellite is currently passing.)

<img width="432" height="454" alt="image" src="https://github.com/user-attachments/assets/522b51e7-a4f4-4637-b86a-d5c2a952261a" />
<img width="428" height="448" alt="image" src="https://github.com/user-attachments/assets/b9d0a672-a03a-4de4-87be-17cce1544570" />

<img width="424" height="137" alt="image" src="https://github.com/user-attachments/assets/e6e0b0d4-db28-45fd-b2e3-6792c2fee9de" />





(6) On iOS or Android devices, clicking any **start time** allows you to add the pass to your **calendar as a reminder**.

(7) Click the **maximum elevation value** to jump to the **real-time satellite tracking** page for that specific pass.

<img width="428" height="177" alt="image" src="https://github.com/user-attachments/assets/f5380fd9-03e0-457c-9132-e709b5c4496e" />


### 3. Real-time Satellite Tracking

**This page displays the satellite's current elevation and azimuth angles, and uses your phone's sensors to assist in antenna alignment by indicating whether you're pointed at the satellite.
Because sensors are used, the page will request sensor permissions. iOS users need to click the "iOS Device Sensor Authorization" button at the bottom of the page to enable access.**

<img width="229" height="34" alt="image" src="https://github.com/user-attachments/assets/fc57dbef-ebde-475d-a2a2-50426ed41696" />


(1) The top **information bar** displays the satellite name, real-time elevation and azimuth, predicted maximum elevation, AOS (acquisition of signal) and LOS (loss of signal) times, current time, and countdown to AOS.

(2) Below the info bar is a progress bar indicating how many seconds have passed since AOS and how many remain until LOS (useful for SSTV reception).

<img width="457" height="186" alt="image" src="https://github.com/user-attachments/assets/e96c9cb5-8bb6-4503-97a8-65cad0d1d84a" />

(3) The central section contains a satellite tracking compass, showing the satellite's pass trajectory and your device's current pointing direction. When the satellite enters the sky, the elevation indicator on the left will show its current elevation, and the central compass will display the satellite's azimuth.

<img width="384" height="329" alt="image" src="https://github.com/user-attachments/assets/bfdc3113-6e53-4db5-a61d-db831b7861f2" />

(4) **Sat Freq Info** displays the satellite's frequency information. Clicking **Doppler Display** will show the satellite's distance and real-time frequency adjusted for Doppler shift.(SSTV: While the satellite is in range, the display also shows recommended reception frequencies for Robot36, Robot72, and PD120 modes. These frequencies are calculated as the midpoint between the current and end-of-pass Doppler-shifted frequencies to minimize the need for manual tuning.)


<img width="462" height="437" alt="image" src="https://github.com/user-attachments/assets/58f308e9-6d0d-4978-9da3-4037a380a833" />
<img width="409" height="477" alt="image" src="https://github.com/user-attachments/assets/d45d1195-0aa6-4ac7-bbd0-8cac1705c503" />





(5) **Start record** allows audio recording, and the recordings can be downloaded to your device. (I personally prefer using the device’s built-in recorder.)
