module counter::counter;

use sui::event;

const E_NOT_OWNER: u64=1;
const E_OVERFLOW: u64=2;

public struct Counter has key
{
    id: UID,
    current_count_value: u64,
    creation_timestamp: u64,
    owner: address
}

public struct CreatedCounterEvent has copy, drop
{
    owner: address,
    creation_timestamp: u64,
}


public struct IncrementedCounterEvent has copy, drop
{
    owner: address,
    current_count_value: u64,
}

entry fun create_counter(ctx: &mut TxContext)
{
    let current_time=tx_context::epoch_timestamp_ms(ctx);
    let sender=tx_context:: sender(ctx);

    let counter = Counter{
        id: object::new(ctx),
        current_count_value: 0,
        creation_timestamp: current_time,
        owner: sender,
    };

    event::emit(CreatedCounterEvent{owner: sender, creation_timestamp: current_time });
    sui::transfer::transfer(counter, sender);

}

entry fun increment(counter: &mut Counter, ctx: &TxContext)
{
    let sender=tx_context::sender(ctx);

    assert!(counter.current_count_value < 1000000, E_OVERFLOW);
    assert!(counter.owner==sender, E_NOT_OWNER);
    
    counter.current_count_value=counter.current_count_value+1;
    event::emit(IncrementedCounterEvent{owner: sender, current_count_value: counter.current_count_value});
}

public fun get_value(counter: &Counter): u64
{
    counter.current_count_value
}

public fun set_value(counter: &mut Counter, value: u64) {
    counter.current_count_value = value;
}
