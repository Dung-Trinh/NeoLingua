![logoAndTextV5](https://github.com/user-attachments/assets/69fd1606-04a8-40fc-bc32-793deec9a21e)

# NeoLingua
This iOS app is a prototype developed as part of a master thesis to explore the use of generative AI for the dynamic creation of personalized learning content in the field of Mobile-Assisted-Language Learning (MALL). In addition, the use of local and image-based contexts was included to create realistic and meaningful learning content.

## Features
* **Context-based learning:** It is possible to enter a prompt or upload an image to set the context to create specific learning content
* **Multimodal generation of learning content:** The following exercises have been created to practice language skills: vocabulary exercise, listening Comprehension and a conversation simulation with an assistant
* **Interactive error correction and feedback:** To support the learning process
* **Integration of gamification aspects:** Designed to make learning fun
* **Scavenger Hunt:** It is a game in which the player has to complete various learning tasks at certain locations, depending on the user's location. Users must move closer to the location in order to unlock the tasks. When all tasks have been completed, the user receives a hint that refers to a specific object, which the user must take a photo of.
* **SnapVocabulary:** An interactive guessing game where you have to guess vocabulary from the picture, and an AI assistant checks the input.

## Preview
**Context-based learning:** 
I took a photo of Big Ben to provide context for context-based learning. The demo video shows the user flow of this feature and focuses especially on the listening comprehension task.

https://github.com/user-attachments/assets/4413a449-60ff-4af1-bffc-7f6dffe8ff46

<br>

**Scavenger Hunt Part 1:** 
In the first part of this video, I create a scavenger hunt based on the user's current location. In addition, the video shows vocabulary tasks where users are presented with contextually relevant words related to their environment. In this example a location is bowling green which is a green area.


https://github.com/user-attachments/assets/a0729af5-8033-4fff-9e6e-7b0b986b0f3c

<br>

**Scavenger Hunt Part 2:** 
In the second video, the conversation simulation for the specific context is demonstrated. It also includes the completion of a location task where the user has to find and take a picture of a specific object in this area.

https://github.com/user-attachments/assets/b33b36ff-5121-440b-a14b-4aca351577cf

## Technologies
* **Integration of Assistants API (OpenAI):**
  - Content created by customized AI assistants
  - Dynamic generation and validation of learning content
  - Providing personalized feedback and error corrections
  - Use of Speech API for the TTS function
 
* **Firebase integration:**
  - **Firebase Auth**: For the administration and authentication of users
  - **Firestore (NoSQL)**: For storing various objects and user data
  - **Firebase Storage**: For storing user-specific images

* **Cloud Functions:** To request data from the Google Places API and to pass this to the Scavenger Hunt assistant to create a scavenger hunt based on the data.
