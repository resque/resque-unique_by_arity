module ResqueSoloUniqueHack
  def unique_key(queue, item)
    # "solo:queue:#{queue}:job:#{const_for(item).redis_key(item)}"
    const_for(item).unique_in_queue_redis_key(queue, item)
    # NOTE: DOES NOT CALL SUPER
  end
end

ResqueSolo::Queue.singleton_class.prepend ResqueSoloUniqueHack
