# delivery_build

Sets up a build node for use in Chef Delivery.

# Requirements

- Chef Delivery

# Attributes

See `attributes/default.rb`.

# Recipes

* `chef_client`: Manages permissions of chef-client directories and files.
* `chefdk`: Installs ChefDK and creates a `.gemrc` for root.
* `cli`: Installs the delivery-cli from package repository or from specified artifact (see `attributes/default.rb`).
* `default`: Includes all the recipes, plus git, to make a build node.
* `repo`: Sets up the package repository (for ChefDK)
* `user`: Manages the delivery build user.
* `workspace`: Manages the delivery workspace.

# License and Author

- Author: Adam Jacob <adam@opscode.com>
- Author: Bakh Inamov <b@chef.io>
- Author: Christopher Maier <cm@chef.io>
- Author: Christopher Webber <cwebber@chef.io>
- Author: Jeremiah Snapp <jeremiah@chef.io>
- Author: Jon Anderson <janderson@chef.io>
- Author: Jon Morrow <jon@morrowmail.com>
- Author: Matt Campbell <mcampbell@chef.io>
- Author: Salim Afiune <afiune@chef.io>
- Author: Seth Falcon <seth@chef.io>
- Author: Tom Duffield <tom@chef.io>
- Author: Joshua Timberman <joshua@chef.io>

- Copyright (c) 2015, Chef Software, Inc. <legal@chef.io>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
