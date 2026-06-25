# Mermaid Render Test — UX Blueprint Sample

> ทดสอบว่า GitHub render Mermaid block ได้ไหม + ใช้ Thai text ได้ไหม
> ถ้าเห็น diagram = OK, ถ้าเห็น code block plain = ไม่ render

---

## 1. User Flow — Checkout One-Tap (ตัวอย่าง)

```mermaid
flowchart TD
    Start([เปิดหน้า Product])
    Cart{มี item ใน cart?}
    Login{Logged in?}
    Address{มี address บันทึก?}
    Payment{มี payment method?}
    Confirm[Tap "Buy Now"]
    Success([Order placed])
    AddAddr[Add address flow]
    AddPay[Add payment flow]
    Loginflow[Login flow]
    EmptyState[Empty cart state]

    Start --> Cart
    Cart -->|Yes| Login
    Cart -->|No| EmptyState
    Login -->|Yes| Address
    Login -->|No| Loginflow
    Loginflow --> Address
    Address -->|Yes| Payment
    Address -->|No| AddAddr
    AddAddr --> Payment
    Payment -->|Yes| Confirm
    Payment -->|No| AddPay
    AddPay --> Confirm
    Confirm --> Success
```

---

## 2. Decision Tree — Edge Cases

```mermaid
flowchart LR
    Tap[User taps Buy Now]
    Net{Network OK?}
    Stock{Stock available?}
    Pay{Payment OK?}
    Done([Success state])
    Retry[Retry banner]
    Sold[Sold-out toast]
    Failed[Payment error modal]

    Tap --> Net
    Net -->|No| Retry
    Net -->|Yes| Stock
    Stock -->|No| Sold
    Stock -->|Yes| Pay
    Pay -->|No| Failed
    Pay -->|Yes| Done
```

---

## 3. Sequence — API Interaction

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant App
    participant API
    participant DB

    User->>App: Tap "Buy Now"
    App->>API: POST /checkout
    API->>DB: Lock inventory
    DB-->>API: ✓ Locked
    API->>API: Charge payment
    API-->>App: Order ID + receipt
    App-->>User: Success screen
    Note over User,App: Toast: "วางขายสำเร็จ"
```

---

## 4. State Diagram — Loading States

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Loading: User taps CTA
    Loading --> Success: Response OK
    Loading --> Error: Response fail
    Error --> Loading: Tap retry
    Success --> [*]
    Error --> Idle: Tap cancel
```

---

## 5. ตัวอย่าง Thai text ใน node

```mermaid
flowchart TD
    A([เริ่มต้น]) --> B{มี Account?}
    B -->|มี| C[เข้าหน้า Dashboard]
    B -->|ไม่มี| D[หน้าลงทะเบียน]
    D --> E[กรอก OTP]
    E -->|สำเร็จ| C
    E -->|ผิด 3 ครั้ง| F[Block 5 นาที]
```

---

## เช็คก่อน confirm

- [ ] GitHub render flowchart ออกมาเป็นภาพ
- [ ] Thai text ใน node แสดงถูก (ไม่กลายเป็น ?)
- [ ] arrow + label render ถูก
- [ ] sequence + state diagram render ได้
- [ ] เปิดใน Notion paste markdown → render ด้วยไหม

> ถ้าทั้งหมดผ่าน → ลุย ux-strategist v2.1 ใช้ Mermaid default ได้
