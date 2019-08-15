# distutils: language=c++
# distutils: sources=hummingbot/core/cpp/OrderBookEntry.cpp

import logging

import numpy as np
import math
from decimal import Decimal

from hummingbot.logger import HummingbotLogger
from hummingbot.core.data_type.order_book_row import OrderBookRow

s_empty_diff = np.ndarray(shape=(0, 4), dtype="float64")
_ddaot_logger = None

cdef class DolomiteActiveOrderTracker:
    def __init__(self, active_asks=None, active_bids=None):
        super().__init__()
        self._active_asks = active_asks or {}
        self._active_bids = active_bids or {}

    @classmethod
    def logger(cls) -> HummingbotLogger:
        global _ddaot_logger
        if _ddaot_logger is None:
            _ddaot_logger = logging.getLogger(__name__)
        return _ddaot_logger

    @property
    def active_asks(self):
        return self._active_asks

    @property
    def active_bids(self):
        return self._active_bids
    

    def volume_for_ask_price(self, price): #Accounts for changing conditions due to partial fills!
        pass
        #return sum([float(msg["availableAmount"]) if 'availableAmount' in msg else (float(msg["primary_amount"]["amount"]) / math.pow(10, msg["primary_amount"]["currency"]["precision"])) - (float(msg["dealt_amount_primary"]["amount"]) / math.pow(10, msg["dealt_amount_primary"]["currency"]["precision"])) for msg in self._active_asks[price].values()])
    
        

    def volume_for_bid_price(self, price):
        pass
        #return sum([float(msg["availableAmount"]) if 'availableAmount' in msg else (float(msg["primary_amount"]["amount"]) / math.pow(10, msg["primary_amount"]["currency"]["precision"])) - (float(msg["dealt_amount_primary"]["amount"]) / math.pow(10, msg["dealt_amount_primary"]["currency"]["precision"])) for msg in self._active_bids[price].values()])
    
    

    cdef tuple c_convert_diff_message_to_np_arrays(self, object message): #msg in list of msgs
        pass 
        
          
         # cdef:
            
         #     str message_type = message.content["order_status"] #OPEN, CANCELLED, FILLED, EXPIRED
         #     object price = Decimal(message.content["exchange_rate"])
         #     double timestamp = message.timestamp
         #     double quantity = 0
         #     str order_type = message.content["order_type"]
                

         # # Only process limit orders
         # if order_type != "LIMIT":
         #     return s_empty_diff, s_empty_diff
        
        
         #DEFINITONS
         #OPEN - Order visible in order books
         #CANCELLED - Order cancelled / removed from order books, blockchain confirmed  
         #EXPIRED - Order expired / removed from order books, blockchain confirmed 
         #FILLED - Order filled / removed from order books, blockhain confirmed 

        
        
         # if message_type == "OPEN": 
            
         #     side = message.content["order_side"]
         #     order_id = message.content["order_hash"]    
            
            
         #     if side == "BUY":
         #         if price in self._active_bids:
         #             #Adds msg content of new order in respective price category (or updates msg content)
         #             self._active_bids[price][order_id] = message.content  
         #         else:
         #             #Adds new price category with msg content of new order
         #             self._active_bids[price] = {order_id: message.content}

         #         quantity = self.volume_for_bid_price(price)
         #         return np.array([[timestamp, float(price), quantity, message.update_id]], dtype="float64"), s_empty_diff
            
         #     elif side == "SELL":
         #         if price in self._active_asks:
         #             self._active_asks[price][order_id] = message.content
         #         else:
         #             self._active_asks[price] = {order_id: message.content}

         #         quantity = self.volume_for_ask_price(price)
         #         return s_empty_diff, np.array([[timestamp, float(price), quantity, message.update_id]], dtype="float64")
            
         #     else:
         #         raise ValueError(f"Unknown order side '{side}'. Aborting.")
                
                

         # elif message_type == "CANCELLED" or message_type == "EXPIRED" or message_type == "FILLED": 
            
         #     side = message.content["order_side"]
         #     order_id = message.content["order_hash"] 
            
         #     if side == "BUY":
         #         if price in self._active_bids:
         #             if order_id in self._active_bids[price]:
         #                 del self._active_bids[price][order_id]
         #             else:
         #                 self.logger().debug(f"Order not found in active bids: {message.content}.")

         #             if len(self._active_bids[price]) < 1:
         #                 del self._active_bids[price]
         #                 return (np.array([[timestamp, float(price), 0.0, message.update_id]], dtype="float64"),
         #                         s_empty_diff)
         #             else:
         #                 quantity = self.volume_for_bid_price(price)
         #                 return (np.array([[timestamp, float(price), quantity, message.update_id]], dtype="float64"),
         #                         s_empty_diff)
         #         else:
         #             return s_empty_diff, s_empty_diff
                
         #     elif side == "SELL":
         #         if price in self._active_asks:
         #             if order_id in self._active_asks[price]:
         #                 del self._active_asks[price][order_id]
         #             else:
         #                 self.logger().debug(f"Order not found in active asks: {message.content}.")

         #             if len(self._active_asks[price]) < 1:
         #                 del self._active_asks[price]
         #                 return (s_empty_diff,
         #                         np.array([[timestamp, float(price), 0.0, message.update_id]], dtype="float64"))
         #             else:
         #                 quantity = self.volume_for_ask_price(price)
         #                 return (s_empty_diff,
         #                         np.array([[timestamp, float(price), quantity, message.update_id]], dtype="float64"))
         #         else:
         #             return s_empty_diff, s_empty_diff
                
         #     else:
         #         raise ValueError(f"Unknown order side '{side}'. Aborting.")
                
         
         # else:
         #     raise ValueError(f"Unknown message type '{message_type}'.")
         

         
            
            

    cdef tuple c_convert_snapshot_message_to_np_arrays(self, object message):
        cdef:
            object price
            str order_id
            str amount

        # Refresh all order tracking.
        self._active_bids.clear()
        self._active_asks.clear()
        
 

        for bid_order in message.content["data"]["buys"]:
        
            price = Decimal(bid_order["exchange_rate"])
            order_id = bid_order["order_hash"]
            amount = (float(bid_order["primary_amount"]["amount"]) / math.pow(10, bid_order["primary_amount"]["currency"]["precision"])) - (float(bid_order["dealt_amount_primary"]["amount"]) / math.pow(10, bid_order["dealt_amount_primary"]["currency"]["precision"]))
            
            
            order_dict = {
                "availableAmount": float(amount),
                "orderId": order_id
            }

            if price in self._active_bids: #Add order in respective price category
                self._active_bids[price][order_id] = order_dict
            else:
                self._active_bids[price] = { #Add new price category with order 
                    order_id: order_dict
                }

        for ask_order in message.content["data"]["sells"]:
            
            price = Decimal(ask_order["exchange_rate"])
            order_id = ask_order["order_hash"]
            amount = (float(ask_order["primary_amount"]["amount"]) / math.pow(10, ask_order["primary_amount"]["currency"]["precision"])) - (float(ask_order["dealt_amount_primary"]["amount"]) / math.pow(10, ask_order["dealt_amount_primary"]["currency"]["precision"]))
            
            order_dict = {
                "availableAmount": float(amount),
                "orderId": order_id
            }

            if price in self._active_asks:
                self._active_asks[price][order_id] = order_dict
            else:
                self._active_asks[price] = {
                    order_id: order_dict
                }

        # Return the sorted snapshot tables.
        cdef:
            np.ndarray[np.float64_t, ndim=2] bids = np.array(
                [[message.timestamp,
                  float(price),
                  sum([float(order_dict["availableAmount"])
                       for order_dict in self._active_bids[price].values()]),
                  message.update_id]
                 for price in sorted(self._active_bids.keys(), reverse=True)], dtype="float64", ndmin=2)
            
            
            np.ndarray[np.float64_t, ndim=2] asks = np.array(
                [[message.timestamp,
                  float(price),
                  sum([float(order_dict["availableAmount"])
                       for order_dict in self._active_asks[price].values()]),
                  message.update_id]
                 for price in sorted(self._active_asks.keys(), reverse=True)], dtype="float64", ndmin=2)

        # If there're no rows, the shape would become (1, 0) and not (0, 4).
        # Reshape to fix that.
        if bids.shape[1] != 4:
            bids = bids.reshape((0, 4))
        if asks.shape[1] != 4:
            asks = asks.reshape((0, 4))

        return bids, asks
    

    def convert_diff_message_to_order_book_row(self, message):
        pass
        
        # np_bids, np_asks = self.c_convert_diff_message_to_np_arrays(message)
        # bids_row = [OrderBookRow(price, qty, update_id) for ts, price, qty, update_id in np_bids]
        # asks_row = [OrderBookRow(price, qty, update_id) for ts, price, qty, update_id in np_asks]
        # return bids_row, asks_row


    def convert_snapshot_message_to_order_book_row(self, message): 
        np_bids, np_asks = self.c_convert_snapshot_message_to_np_arrays(message)
        bids_row = [OrderBookRow(price, qty, update_id) for ts, price, qty, update_id in np_bids]
        asks_row = [OrderBookRow(price, qty, update_id) for ts, price, qty, update_id in np_asks]
        return bids_row, asks_row