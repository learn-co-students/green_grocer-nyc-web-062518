def consolidate_cart(cart)
  # code here
  new_cart = {}
  cart.each do |item|
		item_name = item.keys.first
		if new_cart[item_name] == nil
		  new_cart[item_name] = {
				price: item[item_name][:price],
				clearance: item[item_name][:clearance],
				count: 1
			}
		else
			new_cart[item_name][:count] += 1
		end
	end
	new_cart
end

def apply_coupons(cart, coupons)
  # code here
  coupons.each do |coupon|
    name = coupon[:item]
    if cart[name] && cart[name][:count] >= coupon[:num]
      cart[name][:count] -= coupon[:num]
      if cart["#{name} W/COUPON"] == nil
        cart["#{name} W/COUPON"] = {
            price: coupon[:cost],
            clearance: cart[name][:clearance],
            count: 1
          }
      else    
        cart["#{name} W/COUPON"][:count] += 1
      end
    end
  end 
  cart
end

def apply_clearance(cart)
  # code here
  cart.collect do |item_name, attribute|
    if attribute[:clearance] == true
      attribute[:price] *= 0.8
      attribute[:price] = attribute[:price].round(2)
    end
  end
  cart
end

def checkout(cart, coupons)
  # code here
  consolidate_cart = consolidate_cart(cart)
  couponed_cart = apply_coupons(consolidate_cart, coupons)
  clearanced_cart = apply_clearance(couponed_cart)
  total = 0 
  clearanced_cart.each do |item, attribute|
    total_item = attribute[:price] * attribute[:count]
    total_item = total_item.round(2)
    total += total_item
    total = total.round(2)
  end  
  if total > 100
    total *= 0.9
    total = total.round(2)
  end
  total
end
