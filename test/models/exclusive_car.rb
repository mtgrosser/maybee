class ExclusiveCar < Car

  allows :drivers, :to => [:create, :update, :destroy], :if_subject => :super_powers?, :exclusive => true

end
