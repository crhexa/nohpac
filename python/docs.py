import sys, getopt

if __name__ == "__main__":
    db_file, txt_file = None
    options, args = getopt.getopt(sys.argv[1:], "d:f:", ["database=", "file="])

    for opt, arg in options:
        if opt in ("-d", "--database"):
            db_file = opt
        elif opt in ("-f", "--file"):
            txt_file = opt
        else:
            db_file = None

    if db_file == None or txt_file == None:
        print(f"Usage: python {sys.argv[0]} -d <database file> -f <data file>")
        sys.exit()
