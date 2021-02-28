## python script for 2.2tft screen (12hx32w)
## utilises binance api to collect and show 
## current btc market orders and basic 24hr
## trending data

from binance.client import Client
from binance.exceptions import BinanceAPIException

if __name__ == '__main__':
  api_key = ''
  api_secret = ''

  client = ''

  try:
    client = Client(api_key, api_secret)
  except BinanceAPIException as e:
    print(e.status_code)
    print(e.message)
    print(e.code)

  btc_tickers = client.get_ticker(symbol='BTCAUD')
  btc_avg_price = client.get_avg_price(symbol='BTCAUD')

  total = 0
  count = 1

  print("\033[1;36;40m" + '======= current orders =========' + "\033[1;37;40m")

  try:
    orders = client.get_open_orders()

    for o in orders:
      aud = float(o['origQty']) * float(o['price'])
      total = total + aud
      if str(o['status']) == 'PARTIALLY_FILLED':
        print('  ' + str(count) + ': ' + "\033[1;32;40m" + str("${:,.2f}".format(aud)).rjust(7, ' ') + "\033[1;37;40m" + ' @ ' + "\033[1;35;40m" + str("${:,.0f}".format(float(o['price']))) + "\033[1;37;40m" + ' ' + "\033[1;37;44m" + str(o['status'])[0:7].center(9, ' ') + "\033[1;37;40m") # + ' (' +  str(o['origQty']) + ') ')
      elif str(o['status']) == 'NEW':
        print('  ' + str(count) + ': ' + "\033[1;32;40m" + str("${:,.2f}".format(aud)).rjust(7, ' ') + "\033[1;37;40m" + ' @ ' + "\033[1;35;40m" + str("${:,.0f}".format(float(o['price']))) + "\033[1;37;40m" + ' ' + str(o['status'])[0:7].center(9, ' '))
      else:
        print(str(o['status']))
      count += 1
  except:
    print("  no orders")
    count += 1

  counter = count - 7
  index = 1

  if count < 6:
    print("\033[1;36;40m" + '===== completed orders =========' + "\033[1;37;40m")
    all_orders = client.get_all_orders(symbol='BTCAUD', limit=30)

    for a in sorted(all_orders, reverse=True, key=lambda i: i['orderId']):
      if a['status'] == 'FILLED':
        if counter == 0:
          break

        aud = float(a['origQty']) * float(a['price'])
        print('  ' + str(index) + ': ' + "\033[1;32;40m" + str("${:,.2f}".format(aud)).rjust(7, ' ') + "\033[1;37;40m" + ' @ ' + "\033[1;35;40m" + str("${:,.0f}".format(float(a['price']))) + "\033[1;37;40m" + ' ' + "\033[1;37;44m" + str(a['status'])[0:7].center(9, ' ') + "\033[1;37;40m")
        index = index + 1
        counter = counter + 1

  while counter < 0:
    print()
    counter += 1

  print("\033[1;36;40m" + '========= 24-hr trends =========' + "\033[1;37;40m")
  print("\033[1;37;40m" + '   lowest:  ' + "\033[1;37;40m" + str("${:,.2f}".format((float(btc_tickers['lowPrice'])))))
  print("\033[1;37;40m" + '  highest:  ' + "\033[1;37;40m" + str("${:,.2f}".format((float(btc_tickers['highPrice'])))))

  change = float(btc_tickers['priceChangePercent'])
  if change < 0:
    print("\033[1;37;40m" + '  average:  ' + "\033[1;33;40m" + str("${:,.2f}".format((float(btc_avg_price['price'])))) + '  ' + "\033[1;31;40m" + str(btc_tickers['priceChangePercent']) + '%'.ljust(2, ' ') + "\033[1;37;40m", end="")
  elif change > 0:
    print("\033[1;37;40m" + '  average:  ' + "\033[1;33;40m" + str("${:,.2f}".format((float(btc_avg_price['price'])))) + '  ' + "\033[1;32;40m" + str(btc_tickers['priceChangePercent']) + '%'.ljust(2, ' ') + "\033[1;37;40m", end="")
  elif change == 0:
    print("\033[1;37;40m" + '  average:  ' + "\033[1;33;40m" + str("${:,.2f}".format((float(btc_avg_price['price'])))) + '  ' + str(btc_tickers['priceChangePercent']) + '%'.ljust(2, ' ') + "\033[1;37;40m", end="")
