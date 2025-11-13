
module counter::counter_tests;

use counter::counter::{Self, Counter};
use sui::test_scenario;

const E_NOT_OWNER: u64=1;
const E_OVERFLOW: u64=2;
const E_NOT_0: u64=3;
const E_NOT_INCREMENTED: u64=4;


#[test]
fun create_counter_test()
{
    let user = @0x0;
    let mut scenario=test_scenario::begin(user);

    {
        let mut ctx = test_scenario::ctx(&mut scenario);
        counter::create_counter(ctx);
    };

    
    test_scenario::next_tx(&mut scenario, user);
    
    let mut counter = test_scenario::take_from_sender<Counter>(&scenario);
    assert!(counter::get_value(&counter) == 0, 3);


    test_scenario::return_to_sender(&scenario, counter);
    test_scenario::end(scenario);

}

#[test]
fun test_increment()
{
    let user = @0x0;
    let mut scenario=test_scenario::begin(user);
    {
        let mut ctx = test_scenario::ctx(&mut scenario);
        counter::create_counter(ctx);
    };
    
    test_scenario::next_tx(&mut scenario, user);
    
    let mut counter = test_scenario::take_from_address<Counter>(&scenario, user);
    counter::increment(&mut counter, test_scenario::ctx(&mut scenario));

    let current_value= counter::get_value(&counter);
    assert!(current_value==1, E_NOT_INCREMENTED);

    test_scenario::return_to_address(user, counter);

    test_scenario::end(scenario);
}


#[test]
#[expected_failure(abort_code = counter::E_NOT_OWNER, location=counter)]
fun test_not_owner() 
{
    let user = @0x0;
    let not_owner=@0x1;
    let mut scenario=test_scenario::begin(user);
    {
        let mut ctx = test_scenario::ctx(&mut scenario);
        counter::create_counter(ctx);
    };
    test_scenario::next_tx(&mut scenario, not_owner);
    let mut counter = test_scenario::take_from_address<Counter>(&scenario, user);

    counter::increment(&mut counter, test_scenario::ctx(&mut scenario));

    test_scenario::return_to_address(user, counter);
    test_scenario::end(scenario);
}


#[test]
#[expected_failure(abort_code = counter::E_OVERFLOW, location=counter)]
fun test_overflow() {
    let owner = @0x0;
    let mut scenario = test_scenario::begin(owner);
    {
        let mut ctx = test_scenario::ctx(&mut scenario);
        counter::create_counter(ctx);
    };

    test_scenario::next_tx(&mut scenario, owner);

    let mut counter = test_scenario::take_from_address<Counter>(&scenario, owner);

    counter::set_value(&mut counter, 1_000_000);

    {
        let ctx = test_scenario::ctx(&mut scenario);
        counter::increment(&mut counter, ctx);
    };

    test_scenario::return_to_address(owner, counter);

    test_scenario::end(scenario);
}
