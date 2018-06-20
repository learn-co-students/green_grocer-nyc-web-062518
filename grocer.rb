def couponMatching(cart, coupons)
  couponMatches = 0
  couponsMatchingCart = []
  cart.each do |item, data|
    coupons.each do |coupon|
      if coupon[:item] == item
        couponsMatchingCart.push(item)
      end
    end
  end
  couponMatches = couponsMatchingCart.length
  couponRepeat = true
  identicalCoupons = {}
  uniqueCouponItems = []
  uniqueCouponItems = couponsMatchingCart.uniq

  if uniqueCouponItems != []
    uniqueCouponItems.each do |item|
      couponCount = couponsMatchingCart.count(item)
      identicalCoupons[item] = couponCount
    end
    if ((identicalCoupons.values).uniq)[0] > 1
      couponRepeat = true
    else
      couponRepeat = false
    end
  end
  if couponRepeat
    coupons = coupons.uniq
  end
  return [couponMatches, couponRepeat, identicalCoupons]
end

def consolidate_cart(cart)
  # code here
  itemNames = []
  cart.each do |item|
    itemNames.push(item.keys)
  end
  itemNameList = itemNames.flatten
  uniqueItemList = itemNameList.uniq
  itemCounts = {}
  uniqueItemList.each do |item|
    count = itemNameList.count(item)
    itemCounts[item] = count
  end
  consolidatedCart = {}
  uniqueCart = cart.uniq
  counter = 0
  uniqueCart.each do |hashItem|
    consolidatedCart[uniqueItemList[counter]] = hashItem[uniqueItemList[counter]]
    (consolidatedCart[uniqueItemList[counter]])[:count] = itemCounts[uniqueItemList[counter]]
    counter = counter + 1
  end
  return consolidatedCart
end

def apply_coupons(cart, coupons)
  # code here
  arrayOfMatchingData = couponMatching(cart, coupons)
  couponMatches = arrayOfMatchingData[0]
  couponRepeat = arrayOfMatchingData[1]
  identicalCoupons = arrayOfMatchingData[2]
  numberOfItems = cart.length
  newKey = ""
  newCart = {}
  mergedCart = {}
  numberOfCoupons = coupons.length

  if numberOfCoupons == 1 # One Coupon Application
    cart.each do|item, data|
        coupons.each do |coupon1|
          if cart.has_key?(coupon1[:item]) # Atleast One Coupon matches item in cart
            itemPrice = data[:price]
            itemClearance = data[:clearance]
            itemCount = data[:count]

            newKey = "#{coupon1[:item]}" + " W/COUPON"

            discountedPrice = coupon1[:cost]
            discountedClearance = itemClearance
            couponItemCount = coupon1[:num]
            discountedItemCount = identicalCoupons[item] #couponMatches

            newData = {:price => discountedPrice, :clearance => discountedClearance, :count => discountedItemCount}
            newCart[newKey] = newData
            updatedItemCount = itemCount - couponItemCount

            # Update Discounted Item Count on Cart
            (cart[(coupon1)[:item]])[:clearance] = itemClearance
            (cart[(coupon1)[:item]])[:count] = updatedItemCount.abs
          else # No Coupon matches item in cart
            return cart
          end
        end
      end
  elsif numberOfCoupons > 1 # Multiple Coupon Applications
    if couponRepeat # multiple repeating coupons
       cart.each do |item, data|
        itemPrice = data[:price]
        itemClearance = data[:clearance]
        itemCount = data[:count]
        (coupons.length).times do |counter|
          # Generate Applied Coupon Data
          couponItemName = (coupons[counter])[:item]
          newKey = "#{couponItemName}" + " W/COUPON"
          discountedPrice = (coupons[counter])[:cost]
          discountedClearance = itemClearance
          couponItemCount = (coupons[counter])[:num]
          discountedItemCount = identicalCoupons[item]
          newData = {:price => discountedPrice, :clearance => discountedClearance, :count => discountedItemCount}
          newCart[newKey] = newData
          #itemCount and couponItemCount Check
          updatedItemCount = itemCount
            while updatedItemCount > couponItemCount
              updatedItemCount = updatedItemCount - couponItemCount
            end
          # Update Discounted Item Count on Cart
          (cart[coupons[counter][:item]])[:clearance] = itemClearance
          (cart[coupons[counter][:item]])[:count] = updatedItemCount
        end
       end
    else # multiple unique coupons
      cart.each do |item, data|
        itemPrice = data[:price]
        itemClearance = data[:clearance]
        itemCount = data[:count]
        coupon = {}
        (coupons.length).times do |counter|
          couponItemName = (coupons[counter])[:item]
          if couponItemName == item
            coupon = coupons[counter]
          end
        end
        newKey = "#{coupon[:item]}" + " W/COUPON"
        discountedPrice = coupon[:cost]
        discountedClearance = itemClearance
        couponItemCount = 0
        if coupon.has_key?(:num)
          couponItemCount = coupon[:num]
        else
          couponItemCount = 0
        end
        discountedItemCount = identicalCoupons[item]
        newData = {:price => discountedPrice, :clearance => discountedClearance, :count => discountedItemCount}
        newCart[newKey] = newData

        #itemCount and couponItemCount Check
        updatedItemCount = itemCount - couponItemCount

        # Update Discounted Item Count on Cart
        (cart[item])[:clearance] = itemClearance
        (cart[item])[:count] = updatedItemCount
      end
    end
  else
    return cart
  end
  mergedCart = cart.merge(newCart)
  return mergedCart
end

def apply_clearance(cart)
  # code here
  cart.each do |item, data|
    if data[:clearance] && data[:count] != 0 && !((data[:price]).nil?)
      # Note: clearance also applies to items on discount
      discountedPrice = data[:price] - (0.20 * data[:price])
      (cart[item])[:price] = discountedPrice
    end
  end
  return cart
end

def checkout(cart, coupons)
  # code here
  theCase = 0
  cart.each do |hash|
    hash.each do |item, data|
      if coupons == [] && data.has_key?(:count) # Base Case
        theCase = 1
        #puts "Hello this is case #{theCase}"
      elsif coupons != [] && !(data.has_key?(:count)) && data[:clearance] == false # Coupons
        theCase = 2
        #puts "Hello this is case #{theCase}"
      elsif coupons == [] && !(data.has_key?(:count)) && # Clearance
        theCase = 3
        #puts "Hello this is case #{theCase}"
      else # Coupons and Clearance
        theCase = 4
        #puts "Hello this is case #{theCase}"
      end
    end
  end

  if theCase == 1
    consolidatedCart = consolidate_cart(cart)
    appliedCouponsCart = apply_coupons(consolidatedCart, coupons)
    appliedClearanceCart = apply_clearance(appliedCouponsCart)
    totalCost = 0
    appliedClearanceCart.each do |item, data|
      totalCost = totalCost + (data[:count] * data[:price])
    end
    return totalCost
  elsif theCase == 2
    consolidatedCart = consolidate_cart(cart)
    appliedCouponsCart = apply_coupons(consolidatedCart, coupons)
    totalCost = 0
    appliedCouponsCart.each do |item, data|
      if item.include? "W/COUPON"
        totalCost = totalCost + data[:price]
      else
        totalCost = totalCost + (data[:count] * data[:price])
      end
    end
    return totalCost
  elsif theCase == 3
    consolidatedCart = consolidate_cart(cart)
    appliedClearanceCart = apply_clearance(consolidatedCart)
    totalCost = 0
    appliedClearanceCart.each do |item, data|
      totalCost = totalCost + (data[:count] * data[:price])
    end
    if totalCost > 100
      totalCost = totalCost - (0.1 * totalCost)
    end
    return totalCost
  else # Case 4
    consolidatedCart = consolidate_cart(cart)
    appliedCouponsCart = apply_coupons(consolidatedCart, coupons)
    appliedClearanceCart = apply_clearance(appliedCouponsCart)
    totalCost = 0
    appliedCouponsCart.each do |item, data|
      if !((data[:price]).nil?)
        if item.include? "W/COUPON"
          totalCost = totalCost + data[:price]
        else
          totalCost = totalCost + (data[:count] * data[:price])
        end
      end
    end
    return totalCost
  end
end
