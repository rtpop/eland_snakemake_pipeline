# import libraries
import argparse
import pandas as pd
import networkx as nx
import eland

def parse_arguments():
    parser = argparse.ArgumentParser(description="benchmark filtering methods")

    # Parse args for the main function
    parser.add_argument('--prior_file', type=str, help='Path to edge list file.')
    parser.add_argument('--panda_edgelist', type=str, help='Path to edge list file.')
    parser.add_argument('--filtered_net', type=str, help='Path to filtered network file.')
    parser.add_argument('--output_file', type=str, help='Path to output file.')
    parser.add_argument('--delimiter', type=str, help='Delimiter used in the edge list files')
    parser.add_argument('--resolution', type=float, help='Resolution for modularity calculation')
    parser.add_argument('--max_communities', type=float, help='Maximum number of communities')
    parser.add_argument('--prior_only', type=bool, help='Filter only prior edges')
    
    return parser.parse_args()

def main():
    args = parse_arguments()
    
    # load filtered network
    if args.prior_only:
        print("Loading filtered network")
        prior_fil = pd.read_csv(args.filtered_net, delimiter=args.delimiter)
        eland_fil = eland.filter_panda.filter_panda(args.prior_file, args.panda_edgelist, delimiter=args.delimiter, prior_only=False)
    else:
        print("Loading filtered network")
        eland_fil = pd.read_csv(args.filtered_net, delimiter=args.delimiter)
        prior_fil = eland.filter_panda.filter_panda(args.prior_file, args.panda_edgelist, delimiter=args.delimiter, prior_only=True)
    
    # load panda network as df
    print("Loading PANDA network")
    panda = pd.read_csv(args.panda_edgelist, delimiter=args.delimiter)
    
    # filter based on top n edges
    # n is the number of edges of eland_fil
    top_fil = panda.iloc[:, 2].nlargest(len(eland_fil)).index
    top_fil = panda.loc[top_fil]
    
    # calculate modularity for the three networks
    modularity_eland = eland.filter_panda.calculate_modularity(eland_fil, resolution=args.resolution, comm_mult=args.max_communities)
    modularity_prior = eland.filter_panda.calculate_modularity(prior_fil, resolution=args.resolution, comm_mult=args.max_communities)
    modularity_top = eland.filter_panda.calculate_modularity(top_fil, resolution=args.resolution, comm_mult=args.max_communities)
    
    # convert dataframes to networkx graphs
    eland_graph = nx.from_pandas_edgelist(eland_fil, source=eland_fil.columns[0], target=eland_fil.columns[1], edge_attr=eland_fil.columns[2])
    prior_graph = nx.from_pandas_edgelist(prior_fil, source=prior_fil.columns[0], target=prior_fil.columns[1], edge_attr=prior_fil.columns[2])
    top_graph = nx.from_pandas_edgelist(top_fil, source=top_fil.columns[0], target=top_fil.columns[1], edge_attr=top_fil.columns[2])
    
    # calculate density and number of edges for the three networks
    density_eland = nx.density(eland_graph)
    density_prior = nx.density(prior_graph)
    density_top = nx.density(top_graph)
    
    num_edges_eland = eland_graph.number_of_edges()
    num_edges_prior = prior_graph.number_of_edges()
    num_edges_top = top_graph.number_of_edges()
    
    # create a DataFrame to store the results
    results = pd.DataFrame({
        'Network': ['ELAND filtered PANDA', 'Prior filtered', 'Top filtered'],
        'Modularity': [modularity_eland, modularity_prior, modularity_top],
        'Density': [density_eland, density_prior, density_top],
        'Number of Edges': [num_edges_eland, num_edges_prior, num_edges_top]
    })
    
    # save the results to a CSV file
    results.to_csv(args.output_file, index=False)

if __name__ == '__main__':
    main()
