def bytes(b):
  """ Print bytes in a humanized way """
  def humanize(b, base, suffices=[]):
    bb = int(b)
    for suffix in suffices:
      if bb < base:
        break
      bb /= float(base)
    return "%.2f %s" % (bb, suffix)

  print("Base 1024: ", humanize(
      b, 1024, ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB']))
  print("Base 1000: ", humanize(
      b, 1000, ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB']))
