import argparse
import os
import bihidef

def parse_args():
    parser = argparse.ArgumentParser("Run bihidef")
    parser.add_argument("edgelist_file", nargs="+", type = str, help="Input file(s)")
    parser.add_argument("--filtering_method", type=str, required=True, help="Filtering method to select input file")
    parser.add_argument("--max_res", type = float, help="The maximum resolution to use.")
    parser.add_argument("--comm_mult", type = float, help="The maximum number of communities to find.")
    parser.add_argument("--output_dir", type = str, help="Output directory.")
    parser.add_argument("--output_prefix_reg", type = str, help="Output prefix for regulator communities.")
    parser.add_argument("--output_prefix_tar", type = str, help="Output prefix for target communities.")
    return parser.parse_args()

def main():
    args = parse_args()
    
    # change to output directory
    os.chdir(args.output_dir)
    
    # select input file based on filtering method
    selected_file = next((f for f in args.edgelist_file if args.filtering_method.lower() in f.lower()), None)
    if selected_file is None:
        raise ValueError("No valid input file found for filtering method: {}".format(args.filtering_method))
    
    # edit input file path to be relative to output directory
    selected_file = os.path.join("../../../../../", selected_file)

    # run bihidef
    bihidef.bihidef(filename = selected_file, maxres = args.max_res, comm_mult = args.comm_mult, oR= args.output_prefix_reg, oT = args.output_prefix_tar)

if __name__ == "__main__":
    main()