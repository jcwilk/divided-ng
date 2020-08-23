require Rails.root.join("lib/deferred_call")

DeferredCall.loop_async if !Rails.env.test?
