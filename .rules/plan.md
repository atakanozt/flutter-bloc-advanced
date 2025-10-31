# Flutter Project Setup and Development Tasks

## 🛠 Project Setup & Dependencies

- Create the project using **FVM** (Flutter Version Manager).
- Install all required **Android** and **iOS** dependencies.
  - macOS users should ensure both Android and iOS emulators work.
  - Non-macOS users only need to set up the Android emulator.

---

## 💡 Feature Development

- Build the following screens:
  - **Login**
  - **Register**
  - **Forgot Password**
  - **Home** (after a dummy login, show authenticated user info)
- Add proper **routing** between these screens.
- Each screen should include:
  - **Loading State**
  - **Error State**
  - **Success State** (preferably with pop-ups)

---

## 🧩 Architecture & Structure

- Use **Bloc Architecture** with a **Feature-First Folder Structure**.
- Implement repositories via **abstract interfaces**.
- Access repositories using a **Service Locator** pattern.

---

## 🎨 Assets & Localization

- Add **assets** to pages with **type-safe** imports.
  - _Bonus:_ include **SVG assets**.
- Make the app multilingual:
  - Support **Turkish (tr)** and **English (en)** languages.

---

## 🚀 Bonus Features

1. **Auto-login**: After a successful login, use local storage to keep the user logged in when the app restarts.
2. **Testing**:
   - Add **Bloc and Repository Unit Tests**.
   - Add **Widget Tests**.

---

## ✅ Summary

| Category         | Task                                           |
| ---------------- | ---------------------------------------------- |
| Setup            | FVM project creation, dependency setup         |
| UI               | Login, Register, Forgot Password, Home screens |
| State Management | Bloc Architecture with Feature-First structure |
| Logic            | Abstract Repositories via Service Locator      |
| Localization     | Turkish & English                              |
| Assets           | Type-safe + SVG                                |
| Bonus            | Auto-login, Unit Tests, Widget Tests           |
