from names_dataset import NameDataset
import names

def get_name():
    nd = NameDataset()

    surname = nd.get_random_surname('IN')
    first_name = names.get_first_name()
    return f"{first_name} {surname}"

print(get_name())