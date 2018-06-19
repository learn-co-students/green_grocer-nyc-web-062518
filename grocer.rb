require "pry"
def consolidate_cart(cart)
  cart.each_with_object({}) do |item, new_cart|
    item.each do |object, details|
      if new_cart[object]
        details[:count] += 1
      else
        new_cart[object] = details
        details[:count] = 1
      end
    end
  end
end

def apply_coupons(cart, coupons)
    coupons.each do |hash|
  name = hash[:item]
    #binding.pry
  if cart[name] && cart[name][:count] >= hash[:num]

    if cart["#{name} W/COUPON"]
      cart["#{name} W/COUPON"][:count] += 1
    else

      cart["#{name} W/COUPON"] = {:count => 1, :price => hash[:cost]}
      cart["#{name} W/COUPON"][:clearance] = cart[name][:clearance]
    end
      cart[name][:count] -= hash[:num]
    end
end
        #binding.pry
cart
end

def apply_clearance(cart)
  cart.each do |name, properties|
    if properties[:clearance]
    new_price = properties[:price] * 0.80
    properties[:price] = new_price.round(2)
  end
  end
  cart
end

def checkout(cart, coupons)
  new_cart = consolidate_cart(cart)
  apply_coupons(new_cart, coupons)
  apply_clearance(new_cart)
  cart_total = 0
  new_cart.each do |item, data|
    item_total = data[:price] * data[:count]
    cart_total += item_total
  end
    if cart_total > 100
    cart_total = cart_total * 0.90
    end
  cart_total
end
