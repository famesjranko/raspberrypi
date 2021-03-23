## python3 script for 2.2tft screen (12hx32w)
## utilises binance api to collect and show 
## current btc market orders and basic 24hr
## trending data

from binance.client import Client
from binance.exceptions import BinanceAPIException

if __name__ == '__main__':
  
  ## requrires binance acct api key/secret
  api_key = ''
  api_secret = ''
  
  ## connect to api
  client = ''
  try:
    client = Client(api_key, api_secret)
  except BinanceAPIException as e:
    print(e.status_code)
    print(e.message)
    print(e.code)
    
  ## get api data
  btc_tickers = client.get_ticker(symbol='BTCAUD')
  btc_last_price = client.get_symbol_ticker(symbol='BTCAUD')

  ## get open orders and print
  print("\033[1;36;40m" + 'orders =============== =========' + "\033[1;37;40m")
  total = 0
  count = 1

  try:
    orders = client.get_open_orders()

    if not orders:
      print("  no orders")
      count += 1
    else:
      for o in sorted(orders, reverse=True, key=lambda i: i['price']):
        aud = float(o['origQty']) * float(o['price'])
        total = total + aud

        if str(o['status']) == 'NEW':
          print('  ' + str(count) + ': ' + "\033[1;32;40m" + str("${:,.2f}".format(aud)).rjust(7, ' ') + "\033[1;37;40m" + ' @ ' + "\033[1;35;40m" + str("${:,.0f}".format(float(o['price']))) + "\033[1;37;40m" + ' ' + "\033[1;37;40m" + 'OPEN'.center(9, ' ') + "\033[1;37;40m")
        else:
          print(str(o['status']))
          
        count += 1
        
        if count > 7:
          break
  except:
    print("  no orders")
    count += 1

  ## set how many completed orders to print, depending on how many current orders there are
  if count == 0:
    counter = 6
  elif count == 1:
    counter = 5
  elif count == 2:
    counter = 4
  elif count == 3:
    counter = 3
  elif count == 4:
    counter = 2
  elif count == 5:
    counter = 1
  elif count > 6:
    counter = 0

  ## get completed orders and print
  index = 1
  if count < 7:
    print("\033[1;36;40m" + 'completed ============ =========' + "\033[1;37;40m")
    all_orders = client.get_all_orders(symbol='BTCAUD', limit=100)

    for a in sorted(all_orders, reverse=True, key=lambda i: i['orderId']):
      if a['status'] == 'FILLED':
        aud = float(a['origQty']) * float(a['price'])
        print('  ' + str(index) + ': ' + "\033[1;32;40m" + str("${:,.2f}".format(aud)).rjust(7, ' ') + "\033[1;37;40m" + ' @ ' + "\033[1;35;40m" + str("${:,.0f}".format(float(a['price']))) + "\033[1;37;40m" + ' ' + "\033[1;37;44m" + str(a['status'])[0:7].center(9, ' ') + "\033[1;37;40m")
        index += 1
        counter -= 1
      elif a['status'] == 'PARTIALLY_FILLED':
        aud = float(a['origQty']) * float(a['price'])
        print('  ' + str(index) + ': ' + "\033[1;32;40m" + str("${:,.2f}".format(aud)).rjust(7, ' ') + "\033[1;37;40m" + ' @ ' + "\033[1;35;40m" + str("${:,.0f}".format(float(a['price']))) + "\033[1;37;40m" + ' ' + "\033[1;33;40m" + str(a['status'])[0:7].center(9, ' ') + "\033[1;37;40m")
        index += 1
        counter -= 1

      if counter == -1:
        break

  ## fill in empty lines when needed
  if count == 7:
    for i in range(1):
      print()
  elif not counter == 0:
    while counter > -1:
      print()
      counter -= 1

  ## get 24hr price trend data and print
  print("\033[1;36;40m" + '24hr trend =====================' + "\033[1;37;40m")
  print("\033[1;37;40m" + '  highest:  ' + "\033[1;37;40m" + str("${:,.2f}".format((float(btc_tickers['highPrice'])))))
  print("\033[1;37;40m" + '   lowest:  ' + "\033[1;37;40m" + str("${:,.2f}".format((float(btc_tickers['lowPrice'])))))

  change = float(btc_tickers['priceChangePercent'])
  percent_change = str("{:,.2f}".format(change)) + '%'

  if change < 0:
    print("\033[1;37;40m" + '   latest:  ' + "\033[1;33;40m" + str("${:,.2f}".format((float(btc_last_price['price'])))) + '  ' + "\033[1;31;40m" + percent_change.center(8, ' ') + "\033[1;37;40m", end="")
  elif change > 0:
    print("\033[1;37;40m" + '   latest:  ' + "\033[1;33;40m" + str("${:,.2f}".format((float(btc_last_price['price'])))) + '  ' + "\033[1;32;40m" + percent_change.center(8, ' ') + "\033[1;37;40m", end="")
  elif change == 0:
    print("\033[1;37;40m" + '   latest:  ' + "\033[1;33;40m" + str("${:,.2f}".format((float(btc_last_price['price'])))) + '  ' + percent_change.center(8, ' ') + "\033[1;37;40m", end="")
