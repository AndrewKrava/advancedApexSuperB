/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (after update) {

    OrderHelper.afterUpdate(Trigger.new, Trigger.old);
}