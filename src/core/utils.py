import ast
import os


def get_bool_from_env(name, default_value):
    if name in os.environ:
        value = os.environ[name]
        try:
            return ast.literal_eval(value)
        except ValueError as e:
            raise ValueError('{} is an invalid value for {}'.format(value, name)) from e
    return default_value
