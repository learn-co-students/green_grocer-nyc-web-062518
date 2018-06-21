def consolidate_cart(cart)
  new_hash = {}
  cart.each do |hash|
   hash.each do |types, val|
    if new_hash.has_key?(types)
      new_hash[types][:count] += 1
    else
      new_hash[types] = val
      new_hash[types][:count] = 1
    end
   end
  end
  new_hash
end

def apply_coupons(cart, coupons)
  coupons.each do |coupon|
    if cart[coupon[:item]] && cart[coupon[:item]][:count] >= coupon[:num]
      if cart["#{coupon[:item]} W/COUPON"]
        cart["#{coupon[:item]} W/COUPON"][:count] += 1
      else
        cart["#{coupon[:item]} W/COUPON"] = {:count => 1, :price => coupon[:cost]}
        cart["#{coupon[:item]} W/COUPON"][:clearance] = cart[coupon[:item]][:clearance]
      end
      cart[coupon[:item]][:count] -= coupon[:num]
    end
  end
  cart
end

def apply_clearance(cart)
  cart.each do |items, values|
    if values[:clearance]
      values[:price] = (values[:price] * 0.80).round(2)
    end
  end
end

def checkout(cart, coupons)
  new_hash = consolidate_cart(cart)
  cart = apply_clearance(apply_coupons(new_hash, coupons))
  
  total_value = 0
  cart.each do |item, value|
    total_value += value[:price] * value[:count]
  end
  
  if total_value > 100
    total_value = total_value * 0.9
  end
  
  total_value
end
