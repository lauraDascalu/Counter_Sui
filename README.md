#  Counter Smart Contract (Sui Move)

A simple **Move** smart contract deployed on **Sui Testnet**, allowing users to create and increment their own personal counters.

- Package ID: 0xb124abde0f097fd3ee5707b42960e6612b44913ec7f770211cf7023396fcfa95
- Transaction Hash: 6QTFVeyZto3ttUAMq3tcTYhjTKHU9zUdyXQ1E5bWA9o5
- Check on [Sui Vision](https://suivision.xyz/)

---

## Structure

### Counter Structure
```move
public struct Counter has key {
    id: UID, //unique object identifier
    current_count_value: u64, //the current counter value
    creation_timestamp: u64, //timestamp (milliseconds) when the counter was created
    owner: address //the account that owns this counter
}
```

### Events

#### CreatedCounterEvent: 
Emitted when a new counter is created.
```move
public struct CreatedCounterEvent has copy, drop {
    owner: address,
    current_count_value: u64,
    creation_timestamp: u64,
}
```

#### IncrementedCounterEvent:
Emitted when a counter is incremented.
```move
public struct IncrementedCounterEvent has copy, drop {
    owner: address,
    current_count_value: u64,
}
```

### Functions

#### `create_counter`
- creates a new `Counter` object with `current_count_value = 0` and `owner` set to the sender
- sets `creation_timestamp` using the current epoch timestamp
- emits a `CreatedCounterEvent`

#### `increment`
- increments the counter by 1
- checks that the sender is the owner (`counter.owner == sender`)
- prevents overflow (`counter.current_count_value < 1_000_000`)
- emits an `IncrementedCounterEvent`

#### `get_value`
- returns the current value of the counter (read-only)

#### `set_value`
- used in tests to set the counter value for overflow testing

### Error Codes

| Constant     | Code | Description                                |
|-------------|------|--------------------------------------------|
| E_NOT_OWNER  | 1    | Sender is not the owner of the counter     |
| E_OVERFLOW   | 2    | Counter value exceeded the maximum (1_000_000) |


### Testing

Tests are located in `tests/counter_tests.move`.

**Test Cases:**

- `create_counter_test` – verifies counter creation and initial value 0.
- `test_increment` – checks that a counter can be incremented by the owner.
- `test_not_owner` – ensures a non-owner cannot increment the counter.
- `test_overflow` – ensures increment fails when counter reaches 1,000,000.

**Run tests:**

```bash
sui move test
```

## Deployment

Build and deploy the module:

```bash
sui move build
sui client publish
```

After publishing, note the Package ID and Transaction Digest.
```
│ Published Objects:                                                                            
│  ┌──                                                                                          
│  │ PackageID: 0x3ffd7fb7cc5d2c4f9fb649a463ec102cb78ce459af5e8e12f7120424e6782707              
│  │ Version: 1  

╭───────────────────────────────────────────────────────────────────────────────────────────────
│ Transaction Effects                                                                           
├───────────────────────────────────────────────────────────────────────────────────────────────
│ Digest: 6QTfVeyZto3ttUAMq3tcTYHjTKHU9zUdyXQ1E5bwA9o5                                          │
│ Status: Success                                                                               
│ Executed Epoch: 916                                                                           
```

## Create a counter
```sui client call --package 0xb124abde0f097fd3ee5707b42960e6612b44913ec7f770211cf7023396fcfa95<package_id> --module counter --function create_counter ```

After creating a counter, note the Object ID.
```
╭───────────────────────────────────────────────────────────────────────────────────────────────
│ Object Changes                                                                                
├───────────────────────────────────────────────────────────────────────────────────────────────
│ Created Objects:                                                                              
│  ┌──                                                                                          
│  │ ObjectID: 0x06ba97dceef4c1491ea5394d00a785e4990d87a8dbca11333c94205412c94f82               
│  │ Sender: 0xfa95e4ceb6ffb9a04f0f7bce6677f34b1a3b1585f442b7d638c413d85596ff82                 
│  │ Owner: Account Address ( 0xfa95e4ceb6ffb9a04f0f7bce6677f34b1a3b1585f442b7d638c413d85596ff8 )     
│  │ ObjectType: 0xb124abde0f097fd3ee5707b42960e6612b44913ec7f770211cf7023396fcfa95::counter::Counter  
│  │ Version: 349180919                                                                         
│  │ Digest: 5ZmGbhzA19vx2jh71FXTB1F4kCzkoozHAxDJ4B1f3xtj                                       
│  └──
```

## Increment the counter
```sui client call --package 0xb124abde0f097fd3ee5707b42960e6612b44913ec7f770211cf7023396fcfa95<package_id>  --module counter --function increment --args 0x06ba97dceef4c1491ea5394d00a785e4990d87a8dbca11333c94205412c94f82<object_id> ```

```
╭────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                           |
├────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                               │
│  │ EventID: 2mGTW3So2nWtLL6vGkifPj2toDp7hSbMrCiTCZ8ehb9H:0                                                         │
│  │ PackageID: 0xb124abde0f097fd3ee5707b42960e6612b44913ec7f770211cf7023396fcfa95                                   │
│  │ Transaction Module: counter                                                                                     |
│  │ Sender: 0xfa95e4ceb6ffb9a04f0f7bce6677f34b1a3b1585f442b7d638c413d85596ff82                                      │
│  │ EventType: 0xb124abde0f097fd3ee5707b42960e6612b44913ec7f770211cf7023396fcfa95::counter::IncrementedCounterEvent │
│  │ ParsedJSON:                                                                                                     |
│  │   ┌─────────────────────┬────────────────────────────────────────────────────────────────────┐                  │
│  │   │ current_count_value │ 1                                                                  |                  |
│  │   ├─────────────────────┼────────────────────────────────────────────────────────────────────┤                  │
│  │   │ owner               │ 0xfa95e4ceb6ffb9a04f0f7bce6677f34b1a3b1585f442b7d638c413d85596ff82 │                  │
```

### View the object
```sui client object 0x06ba97dceef4c1491ea5394d00a785e4990d87a8dbca11333c94205412c94f82<object_id> ```
```
╭───────────────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ objectId      │  0x06ba97dceef4c1491ea5394d00a785e4990d87a8dbca11333c94205412c94f82                                                             │
│ version       │  349180922                                                                                                                      │
│ digest        │  AMgLQawY6beofpDjUB13aqiMEj4V9tuPdZLZVjnpkNcX                                                                                   │
│ objType       │  0xb124abde0f097fd3ee5707b42960e6612b44913ec7f770211cf7023396fcfa95::counter::Counter                                           │
│ owner         │ ╭──────────────┬──────────────────────────────────────────────────────────────────────╮                                         │
│               │ │ AddressOwner │  0xfa95e4ceb6ffb9a04f0f7bce6677f34b1a3b1585f442b7d638c413d85596ff82  │                                         │
│               │ ╰──────────────┴──────────────────────────────────────────────────────────────────────╯                                         │
│ prevTx        │  3Qqe3G8zp6eKLAAXM3ACBJgzZhNTsnMsDv2vG3GWJhzu                                                                                   │
│ storageRebate │  1664400                                                                                                                        │
│ content       │ ╭───────────────────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │
│               │ │ dataType          │  moveObject                                                                                             │ │
│               │ │ type              │  0xb124abde0f097fd3ee5707b42960e6612b44913ec7f770211cf7023396fcfa95::counter::Counter                   │ │
│               │ │ hasPublicTransfer │  false                                                                                                  │ │
│               │ │ fields            │ ╭─────────────────────┬───────────────────────────────────────────────────────────────────────────────╮ │ │
│               │ │                   │ │ creation_timestamp  │  1762896167636                                                                │ │ │
│               │ │                   │ │ current_count_value │  2                                                                            │ │ │
│               │ │                   │ │ id                  │ ╭────┬──────────────────────────────────────────────────────────────────────╮ │ │ │
│               │ │                   │ │                     │ │ id │  0x06ba97dceef4c1491ea5394d00a785e4990d87a8dbca11333c94205412c94f82  │ │ │ │
│               │ │                   │ │                     │ ╰────┴──────────────────────────────────────────────────────────────────────╯ │ │ │
│               │ │                   │ │ owner               │  0xfa95e4ceb6ffb9a04f0f7bce6677f34b1a3b1585f442b7d638c413d85596ff82           │ │ │
│               │ │                   │ ╰─────────────────────┴───────────────────────────────────────────────────────────────────────────────╯ │ │
│               │ ╰───────────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────╯ │
╰───────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```
#### Also check on [Sui Vision](https://suivision.xyz/)

<img width="1750" height="589" alt="image" src="https://github.com/user-attachments/assets/3a7d4e99-60a4-4241-bc97-1c00e3fa05ad" />


  
