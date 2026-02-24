import csv
import json
import os


def extract_times_to_csv(input_files, output_file):
    with open(output_file, "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["mode", "time"])
        data_count = 0

        for filename in input_files:
            try:
                with open(filename, "r") as f:
                    data = json.load(f)
                    times = data["results"][0]["times"]
                    config_name = os.path.basename(filename).replace(".json", "")
                    for t in times:
                        writer.writerow([config_name, t])
                        data_count += 1

                print(f"Extracted {len(times)} rows for '{config_name}'")

            except FileNotFoundError:
                print(f"Warning: Could not find {filename}. Skipping.")
            except KeyError:
                print(f"Warning: Unexpected JSON structure in {filename}. Skipping.")
            except Exception as e:
                print(f"Error processing {filename}: {e}")
    if data_count > 0:
        print(f"\nSuccessfully wrote {data_count} total data points to {output_file}")
    else:
        print("No data extracted.")


if __name__ == "__main__":
    dir = "./target/bench/"
    paths = [
        os.path.abspath(os.path.join(dir, f))
        for f in os.listdir(dir)
        if f.endswith(".json")
    ]
    output_csv_name = "data.csv"
    extract_times_to_csv(paths, output_csv_name)
