try{
    firebase.initializeApp(config);
} catch (err) {
    // we skip the "already exists" message which is
    // not an actual error when we're hot-reloading
    if (!/already exists/.test(err.message)) {
        console.error('Firebase initialization error', err.stack)
    }
}

function checkUserAdmin(){
    return firebase.auth().currentUser.getIdToken().then(idToken => {
        const payload = JSON.parse(b64DecodeUnicode(idToken.split('.')[1]));
       // Confirm the user is an Admin.
       return payload['admin'];
    });
}

function loadAnalytics(){

}

function signout(){
    firebase.auth().signOut().then(function() {
      // Sign-out successful.
      console.log("Sign out successful!");
    }).catch(function(error) {
      console.log("Error logging out:")
      console.log(error);
    });
}

function b64DecodeUnicode(str) {
    // Going backwards: from bytestream, to percent-encoding, to original string.
    return decodeURIComponent(atob(str).split('').map(function(c) {
        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));
}

function isObject(val) {
    if (val === null) { return false;}
    return ( (typeof val === 'function') || (typeof val === 'object') );
}

function DropletPage(){
    var _self = this; 

    this.loadingFnc = null;

    this.$table = null;
    this.rowTemplateName = '';

    this.$searchField = null;
    this.$nextButton = null;
    this.$previousButton = null;

    this.$sortKeyElements = null;
    this.sortBy = null;
    this.sortDesc = true;

    this.maximumSortValue = null;
    this.nextKey = null;
    this.prevKey = null;

    this.limit = 11;

    this.currentRef = null;

    this.setTable = function($table){
        this.$table = $table;
        this.$sortKeyElements = this.$table.find("[data-role='sort-key']");
        this.$sortKeyElements.on("click", $.proxy(this.changeSorting, this));
        this.updateSorting();
    }

    this.configureLimitListener = function($mainContainer){
        $mainContainer.find("[data-role='limit']").on("click", $.proxy(this.changeLimit, this));
    }

    this.changeLimit = function(event){
        var $element = $(event.target);
        if(this.limit != $element.data('limit') + 1){
            this.limit = $element.data('limit') + 1;
            this.reset();
            this.loadingFnc(this);
        }
    }

    this.changeSorting = function(event){
        var $sortElement = $(event.target);

        if($sortElement.closest(".table").hasClass(".no-sorting")){
            return;
        }

        if($sortElement.attr("data-active") === 'true'){
            //$sortElement.data("desc", !$sortElement.data("desc"));
            $sortElement.attr("data-desc", !($sortElement.attr("data-desc") == 'true'));
        }else{
            //this.$sortKeyElements.find("[data-active='true']").data("active", false);
            var activeElement = this.$sortKeyElements.filter(function(){
                return $(this).attr("data-active") === 'true';
            });
            //activeElement.data("active", false);
            activeElement.attr("data-active", false);
            //$sortElement.data("desc", true);
            $sortElement.attr("data-desc", true);
            //$sortElement.data("active", true);
            $sortElement.attr("data-active", true);
        }
        this.updateSorting();
        this.reset();
        this.loadingFnc(this);
    }

    this.updateSorting = function(){
        var activeElement = this.$sortKeyElements.filter(function(){
            return $(this).attr("data-active") === 'true';
        });
        this.sortBy = activeElement.attr("data-name");
        this.sortDesc = (activeElement.attr("data-desc") === 'true');
        activeElement.append('')
    }

    this.setNextKey = function(key){
        _self.nextKey = key;
        _self.updateButtonStates();
    };

    this.setPrevKey = function(key){
        _self.prevKey = key;
        _self.updateButtonStates();
    };

    this.disablePagination = function(){
        _self.$nextButton.closest('.page-item').addClass('disabled');
        _self.$previousButton.closest('.page-item').addClass('disabled');
    }

    this.updateButtonStates = function(){
        if(_self.$nextButton != null){
            if(_self.nextKey == null){
                _self.$nextButton.closest('.page-item').addClass('disabled');
            }else{
                _self.$nextButton.closest('.page-item').removeClass('disabled');
            }
        }

        if(_self.$previousButton != null){
            if(_self.prevKey == null){
                _self.$previousButton.closest('.page-item').addClass('disabled');
            }else{
                _self.$previousButton.closest('.page-item').removeClass('disabled');
            }
        }
    }

    this.reset = function(){
        this.maximumSortValue = null;
        this.nextKey = null;
        this.prevKey = null;
    }

    this.updatePagination = function(objects){
        var sortBy = (this.sortBy == null ? 'id' : this.sortBy);

        if(objects.length == 0){
            this.setPrevKey(null);
            this.setNextKey(null);
            return;
        }

        if(this.maximumSortValue == null){
            this.maximumSortValue = objects[0][sortBy];
        }
        if(this.sortDesc){
            this.setPrevKey(objects[0][sortBy] < this.maximumSortValue ? objects[0][sortBy] : null);
        }else{
            this.setPrevKey(objects[0][sortBy] > this.maximumSortValue ? objects[0][sortBy] : null);
        }
        this.setNextKey((objects.length < this.limit ? null : objects[objects.length - 1][sortBy]));
    }

    this.refWithSorting = function(ref){
        if(this.sortBy == null){
            ref = ref.orderByKey();
        }else{
            ref = ref.orderByChild(this.sortBy);
        }
        return ref;
    }

    this.initialRef = function(ref){
        if(this.sortDesc){
            ref = this.refWithSorting(ref).limitToLast(this.limit);
        }else{
            ref = this.refWithSorting(ref).limitToFirst(this.limit);
        }
        this.currentRef = ref;
        return ref;
    }

    this.refForNext = function(ref){
        if(this.sortDesc){
            ref = this.refWithSorting(ref).endAt(this.nextKey).limitToLast(this.limit);
        }else{
            ref = this.refWithSorting(ref).startAt(this.nextKey).limitToFirst(this.limit);
        }
        this.currentRef = ref;
        return ref;
    }

    this.refForPrev = function(ref){
        if(this.sortDesc){
            ref = this.refWithSorting(ref).startAt(this.prevKey).limitToFirst(this.limit);
        }else{
            ref = this.refWithSorting(ref).endAt(this.prevKey).limitToLast(this.limit);
        }
        this.currentRef = ref;
        return ref;
    }
}


var DropletAdmin = new function(options) {
    var _self = this;

    this.imageCache = {}

    this.loggedInLabel = $('[data-role="logged-in-user"]');

    this.$notice = $('[data-role="notice-container"]');

    this.$loadingCover = $('[data-role="loading-cover"]');

    this.$dashboardlink = $('[data-role="dashboard-link"]');
    this.$chatslink = $('[data-role="chats-link"]');
    this.$userslink = $('[data-role="users-link"]');
    this.$reportslink = $('[data-role="reports-link"]');

    this.$mainContainer = $('[data-role="main-container"]');

    this.dashboardReportsPage = new DropletPage();
    this.dashboardUsersPage = new DropletPage();
    this.dashboardChatsPage = new DropletPage();

    this.usersPage = new DropletPage();
    this.chatsPage = new DropletPage();
    this.reportsPage = new DropletPage();

    this.$dashboardlink.on('click', function(){
        _self.loadDashboardPage();
    });

    this.$userslink.on('click', function(){
        _self.loadUsersPage();
    });

    this.$chatslink.on('click', function(){
        _self.loadChatsPage();
    });

    this.$reportslink.on('click', function(){
        _self.loadReportsPage();
    });

    firebase.auth().onAuthStateChanged(function(user){
        if (user) {
            // Confirm the user is an Admin.
            firebase.auth().currentUser.getIdToken().then(idToken => {
                const payload = JSON.parse(b64DecodeUnicode(idToken.split('.')[1]));
                if(!!payload['admin']){
                    console.log("Is Admin, continue!");
                    _self.loggedInLabel.html(firebase.auth().currentUser.email);
                    _self.$loadingCover.hide();
                }else{
                    console.log("Not an admin, logging out!");
                    _self.logout();
                }
            });
        }else{
            window.location = 'login.html';
        }
    });

    this.initialize = function(){
        console.log("Faux Initialize");
        _self.loadImageCache();
        _self.attachGlobalListeners();
        _self.loadDashboardPage();
        _self.setAnalyticsURL();
    };

    this.setAnalyticsURL = function(){
        $("#analytics-link").prop('href', 'https://console.firebase.google.com/project/'+config.projectId+'/analytics/overview');
    }

    this.loadImageCache = function(){
        var _self = this;
        if(_self.storageAvailable('localStorage')){
            console.log("Local Storage Available!");
            var storedImageCache = localStorage.getItem('imageCache');
            console.log("Stored Image Cache", storedImageCache);
            if(storedImageCache){
                try{
                    _self.imageCache = JSON.parse(storedImageCache);
                }catch(e){
                    console.log("Error loading image cache");
                }
            }
        }
    }

    this.addToImageCache = function(ref, downloadURL){
        var _self = this;
        _self.imageCache[ref] = downloadURL;
        if(_self.storageAvailable('localStorage')){
            localStorage.setItem('imageCache', JSON.stringify(_self.imageCache));
        }
    }

    this.storageAvailable = function storageAvailable(type) {
        try {
            var storage = window[type],
                x = '__storage_test__';
            storage.setItem(x, x);
            storage.removeItem(x);
            return true;
        }
        catch(e) {
            return e instanceof DOMException && (
                // everything except Firefox
                e.code === 22 ||
                // Firefox
                e.code === 1014 ||
                // test name field too, because code might not be present
                // everything except Firefox
                e.name === 'QuotaExceededError' ||
                // Firefox
                e.name === 'NS_ERROR_DOM_QUOTA_REACHED') &&
                // acknowledge QuotaExceededError only if there's something already stored
                storage.length !== 0;
        }
    }

    this.logout = function(){
        firebase.auth().signOut().then(function() {
          console.log("Logged out, redirecting...");
        }).catch(function(error) {
          console.log("Error logging out:")
          console.log(error);
        });
    };

    this.reloadCurrentPage = function(){

    };

    this.updateActiveLink = function($elementToMakeActive){
        $(".internal-load.active").removeClass("active");
        $elementToMakeActive.addClass("active");
    }

    this.loadDashboardPage = function(){
        _self.updateActiveLink(_self.$dashboardlink);
        _self.$mainContainer.load("dashboard.html", function(){
            //_self.loadChats();
            //_self.$dashboardReportsTable = _self.$mainContainer.find('[data-role="dashboard-reports-table"]');

            _self.dashboardReportsPage.$table = _self.$mainContainer.find('[data-role="dashboard-reports-table"]');
            _self.dashboardReportsPage.rowTemplateName = "reportrow";
            _self.dashboardReportsPage.sortBy = "last_reported";
            _self.dashboardReportsPage.sortDesc = true;
            _self.dashboardReportsPage.limit = 6;
            _self.loadReports(_self.dashboardReportsPage)

            _self.dashboardUsersPage.$table = _self.$mainContainer.find('[data-role="dashboard-users-table"]');
            _self.dashboardUsersPage.rowTemplateName = "miniuserrow";
            _self.dashboardUsersPage.sortBy = "created_at";
            _self.dashboardUsersPage.sortDesc = true;
            _self.dashboardUsersPage.limit = 6;
            _self.loadUsers(_self.dashboardUsersPage)

            _self.dashboardChatsPage.$table = _self.$mainContainer.find('[data-role="dashboard-chats-table"]');
            _self.dashboardChatsPage.rowTemplateName = "chatrow";
            _self.dashboardChatsPage.sortBy = null;
            _self.dashboardChatsPage.sortDesc = true;
            _self.dashboardChatsPage.limit = 6;
            _self.loadChats(_self.dashboardChatsPage)

            //_self.$dashboardChatsTable = _self.$mainContainer.find('[data-role="dashboard-chats-table"]');
        });
    }

    this.loadUsersPage = function(query){
        var _self = this;

        _self.updateActiveLink(_self.$userslink);

        _self.$mainContainer.load("users.html", function(){
            _self.usersPage.sortBy = "name";

            //_self.usersPage.$table = _self.$mainContainer.find('[data-role="users-table"]');
            _self.usersPage.setTable(_self.$mainContainer.find('[data-role="users-table"]'));
            _self.usersPage.configureLimitListener(_self.$mainContainer);
            _self.usersPage.rowTemplateName = "userrow";

            _self.usersPage.$searchField = _self.$mainContainer.find("[data-role='search-field']");
            _self.usersPage.$searchField.on("blur", $.proxy(_self.searchUsers, _self, _self.usersPage.$searchField));
            _self.usersPage.$searchField.on("focus", $.proxy(_self.configureSearchInput, _self, _self.usersPage.$searchField));

            _self.usersPage.$nextButton = _self.$mainContainer.find('[data-role="page-next"]');
            _self.usersPage.$previousButton = _self.$mainContainer.find('[data-role="page-prev"]');

            _self.usersPage.$nextButton.on("click", $.proxy(_self.loadNextUsers, _self));
            _self.usersPage.$previousButton.on("click", $.proxy(_self.loadPreviousUsers, _self));

            _self.usersPage.loadingFnc = $.proxy(_self.loadUsers, _self);

            if(query && query.length > 0){
                _self.loadUsersForQuery(query);
            }else{
                //_self.loadUsers(_self.usersPage);
                _self.reloadCurrentUsers(_self.usersPage);
            }
        });
    }

    this.loadNextUsers = function(){
        var _self = this;
        if(_self.usersPage.nextKey == null){
            return;
        }
        var ref = firebase.database().ref('/users');
        ref = this.usersPage.refForNext(ref);
        return ref.once('value').then($.proxy(_self.loadedUsers, _self, _self.usersPage));
    };

    this.loadPreviousUsers = function(){
        var _self = this;
        if(this.usersPage.prevKey == null){
            return;
        }
        var ref = firebase.database().ref('/users');
        ref = this.usersPage.refForPrev(ref);
        return ref.once('value').then($.proxy(_self.loadedUsers, _self, _self.usersPage));
    };

    this.loadUsers = function(page){
        var _self = this;

        if(_self.usersPage.$table){
            _self.usersPage.$table.removeClass("no-sorting");
        }

        var ref = firebase.database().ref('/users');
        ref = page.initialRef(ref);
        _self.showLoadingCover();
        return ref.once('value').then($.proxy(_self.loadedUsers, _self, page));
    };

    this.reloadCurrentUsers = function(){
        var _self = this;
        var ref = _self.usersPage.currentRef;
        if(ref){
            return ref.once('value').then($.proxy(_self.loadedUsers, _self, _self.usersPage));
        }else{
            return this.loadUsers(_self.usersPage);
        }
    }

    this.searchUsers = function($searchField, event){
        if(this.configureSearchTags($searchField)){
            var query = $searchField.val();
            this.loadUsersForQuery(query);
        }
    }

    this.loadUsersForQuery = function(query, event){
        var _self = this;

        if(!query || query.length == 0){
            this.loadUsers(_self.usersPage);
            return;
        }

        _self.usersPage.$table.addClass("no-sorting");
        _self.usersPage.disablePagination();

        this.showLoadingCover();

        console.log("Searching for Users", query);

        var promises = [];
        var IDSearch = firebase.database().ref('/users').orderByKey().startAt(query).endAt(query+"\uf8ff").once('value');
        promises.push(IDSearch);
        var NameSearch = firebase.database().ref('/users').orderByChild('name').startAt(query).endAt(query+"\uf8ff").once('value');
        promises.push(NameSearch);

        return Promise.all(promises).then(function(results){

            var objects = [];
            $.each(results, function(idx, snapshot){
                objects.push.apply(objects, _self.parseObjects(snapshot, true));
            });

            console.log(objects);

            var foundIDs = [];
            $.grep(objects, function(idx, object){
                if($.inArray(object.id, foundIDs) != -1){
                    return false;
                }
                foundIDs.push(object.id);
                return true;
            });

            //_self.loadedUsers();
            _self.displayObjects("userrow", _self.usersPage, objects);
            _self.hideLoadingCover();
        });
    };

    this.loadedUsers = function(page, snapshot){
        console.log("Loaded Users With Snapshot:", snapshot);
        console.log("Loaded Users With Page:", page);
        var objects = _self.parseObjects(snapshot, page.sortDesc);
        page.updatePagination(objects);
        _self.displayObjects(page.rowTemplateName, page, objects);
        _self.hideLoadingCover();
    };

    this.showUser = function(event){
        if($(event.target).closest(".exclude-row-click").length){
            return;
        }
        var user = $(event.currentTarget).data('jsonstring');

        if(user){
            _self.showModal(user, "usermodal");
        }
    };

    this.showCreateChatDialog = function(event){
        var _self = this;
        var userOneID = $(event.currentTarget).data('id');

        if(!userOneID || userOneID.length == 0){
            return;
        }
        var userTwoID = prompt("Create chat with: (userID)", "");
        if (userTwoID != null && userTwoID != "") {
            this.createChat(userOneID, userTwoID);
        }
    };

    this.createChat = function(userOneID, userTwoID){
        var _self = this;

        var updates = {};
        updates['user_likes/'+userOneID+'/'+userTwoID] = true;
        updates['user_likes/'+userTwoID+'/'+userOneID] = true;

        _self.showLoadingCover();
        return firebase.database().ref().update(updates).then(function(results){
            _self.showNotice("Chat Scheduled For Creation");
        });
    }

    this.deleteUserImage = function(event){
        var _self = this;

        var $element = $(event.currentTarget);
        var $imagesSlider = $element.closest(".user-images-slider");
        var images = $imagesSlider.data("images");
        var index = $element.data("index");
        var userID = $element.data("id");
        if(!images || index == null){
            return;
        }
        var ref = images[index];

        _self.showConfirmationDialog(
            "Delete Image",
            "Are you sure you want to delete this image? <strong>This cannot be undone</strong>",
            "danger",
            "Delete Image",
            function(modal){

                _self.showLoadingCover(0.6);
                console.log("Deleting image");
                images.splice(index, 1);
                return firebase.database().ref('users/'+userID+'/images').set(images)
                    .then(function(){
                        firebase.storage().ref(ref).delete()
                            .then(function(){
                                console.log("File deleted successfully");
                            })
                            .catch(function(error){
                                console.log("Error deleting file", error);
                            });
                        $imagesSlider.slick("slickRemove", index);
                        _self.reloadCurrentUsers();
                        modal.modal('hide');
                        _self.hideLoadingCover();
                    })
                    .catch(function(error){
                        modal.modal('hide');
                        _self.showNotice("Error: "+error.message);
                    });

            }, function(){
                console.log("Did cancel dialog");
            });
    };

    this.changeUserEnabled = function(banned, event){

        var _self = this;
        var userID = $(event.currentTarget).data('id');

        console.log("Changing User Enabled Status", userID);

        if(!userID || userID.length == 0){
            return;
        }
        _self.showLoadingCover(0.6);

        var updates = {}
        updates['banned/'+userID] = banned;
        updates['users/'+userID+'/banned'] = banned;

        firebase.database().ref().update(updates)
            .then(function(){
                _self.reloadCurrentUsers();
                _self.showNotice("User " + (banned ? "Disabled" : "Enabled"));
            })
            .catch(function(error){
                _self.showNotice("Error: "+error.message);
            });
    }

    this.deleteUser = function(event){
        var _self = this;
        var userID = $(event.currentTarget).data('id');

        if(!userID || userID.length == 0){
            return;
        }

        this.showConfirmationDialog(
            "Delete User",
            "Are you sure you want the delete this user? <strong>This action cannot be undone!</strong>",
            "danger",
            "Delete User",
            function(modal){
                _self.showLoadingCover(0.6);
                firebase.database().ref('/users/'+userID).remove()
                .then(function(){
                    _self.hideAllModals();
                    _self.reloadCurrentUsers();
                    _self.showNotice("User Deleted");
                })
                .catch(function(error){
                    modal.modal('hide');
                    _self.showNotice("Error: "+error.message);
                });
            },
            function(){
                console.log("Did cancel dialog");
            }
        );
    }


    /*
     * Chats Methods
     */

    this.loadChatsPage = function(query){
        console.log("Loading chats page for query: ",query);
        var _self = this;
        _self.updateActiveLink(_self.$chatslink);
        _self.$mainContainer.load("chats.html", function(){
            //_self.chatsPage.$table = _self.$mainContainer.find('[data-role="chats-table"]');
            _self.chatsPage.setTable(_self.$mainContainer.find('[data-role="chats-table"]'));
            _self.chatsPage.configureLimitListener(_self.$mainContainer);

            _self.chatsPage.rowTemplateName = "chatrow";

            _self.chatsPage.$searchField = _self.$mainContainer.find("[data-role='search-field']");
            _self.chatsPage.$searchField.on("blur", $.proxy(_self.searchChats, _self, _self.chatsPage.$searchField));
            _self.chatsPage.$searchField.on("focus", $.proxy(_self.configureSearchInput, _self, _self.chatsPage.$searchField));

            _self.chatsPage.$nextButton = _self.$mainContainer.find('[data-role="page-next"]');
            _self.chatsPage.$previousButton = _self.$mainContainer.find('[data-role="page-prev"]');

            _self.chatsPage.$nextButton.on("click", $.proxy(_self.loadNextChats, _self));
            _self.chatsPage.$previousButton.on("click", $.proxy(_self.loadPreviousChats, _self));

            _self.chatsPage.loadingFnc = $.proxy(_self.loadChats, _self);

            if(query && query.length > 0){
                console.log("Loading for query:", query);
                _self.chatsPage.$searchField.val(query);
                _self.configureSearchTags(_self.chatsPage.$searchField)
                _self.loadChatsForQuery(query);
            }else{
                //_self.loadChats(_self.chatsPage);
                _self.reloadCurrentChats(_self.chatsPage);
            }
        });
    }

    this.viewChats = function(event){
        console.log("Showing Chats!");
        var $element = $(event.currentTarget);
        var query = $element.data("id");
        if(query){
            this.hideAllModals();
            this.loadChatsPage(query);
        }
    }

    this.loadNextChats = function(){
        var _self = this;
        if(this.chatsPage.nextKey == null){
            return;
        }
        var ref = firebase.database().ref('/chats');
        ref = this.chatsPage.refForNext(ref);
        return ref.once('value').then($.proxy(_self.loadedChats, _self, _self.chatsPage));
    };

    this.loadPreviousChats = function(){
        var _self = this;
        if(this.chatsPage.prevKey == null){
            return;
        }
        var ref = firebase.database().ref('/chats');
        ref = this.chatsPage.refForPrev(ref);
        return ref.once('value').then($.proxy(_self.loadedChats, _self, _self.chatsPage));
    };

    this.loadChats = function(page){
        var _self = this;

        if(_self.chatsPage.$table){
            _self.chatsPage.$table.removeClass("no-sorting");
        }

        var ref = firebase.database().ref('/chats');
        ref = page.initialRef(ref);
        return ref.once('value').then($.proxy(_self.loadedChats, _self, page));
    };

    this.reloadCurrentChats = function(){
        var _self = this;
        var ref = _self.chatsPage.currentRef;
        if(ref){
            return ref.once('value').then($.proxy(_self.loadedChats, _self, _self.chatsPage));
        }else{
            return this.loadChats(_self.chatsPage);
        }
    }

    this.searchChats = function($searchField, event){
        if(this.configureSearchTags($searchField)){
            var query = $searchField.val();
            this.loadChatsForQuery(query);
        }
    }

    this.loadChatsForQuery = function(query, event){
        var _self = this;

        if(query.length == 0){
            this.loadChats(_self.chatsPage);
            return;
        }

        _self.chatsPage.$table.addClass("no-sorting");
        _self.chatsPage.disablePagination();
        this.showLoadingCover();

        var ref = firebase.database().ref("/user_chats/"+query);
        return ref.once('value').then(function(snapshot){
            var promises = [];
            snapshot.forEach(function(childSnapshot){
                var chatPromise = firebase.database().ref("/chats/"+childSnapshot.key).once('value');
                promises.push(chatPromise);
            });
            return Promise.all(promises).then(function(results){
                var objects = [];
                $.each(results, function(idx, snapshot){
                    var object = snapshot.val();
                    object.id = snapshot.key;
                    objects.push(object);
                });
                objects.sort(function(a, b){
                    return b.updated_at - a.updated_at;
                });
                return _self.loadChatOpponents(objects).then(function(chatObjects){
                    _self.displayObjects("chatrow", _self.chatsPage, chatObjects);
                    _self.hideLoadingCover();
                });
            });
        });
    };

    this.loadedChats = function(page, snapshot){
        var objects = _self.parseObjects(snapshot, page.sortDesc);
        page.updatePagination(objects);
        return _self.loadChatOpponents(objects).then(function(chatObjects){
            _self.displayObjects(page.rowTemplateName, page, chatObjects);
        });
    };

    this.loadChatOpponents = function(chatObjects){
        var promises = [];
        $.each(chatObjects, function(idx, chat){
            if(chat.occupants){
                $.each(Object.keys(chat.occupants), function(jdx, occupantId){
                    promises.push(firebase.database().ref("users/"+occupantId).once('value'));
                });
            }
        });
        return Promise.all(promises).then(function(results){
            var users = {};
            $.each(results, function(idx, result){
                if(result && result.val()){
                    var user = result.val();
                    user.id = result.key;
                    users[user.id] = user;
                }
            });
            $.each(chatObjects, function(idx, chat){
                if(chat.occupants){
                    $.each(Object.keys(chat.occupants), function(jdx, occupantId){
                        if(users[occupantId]){
                            chatObjects[idx].occupants[occupantId] = users[occupantId];
                        }
                    });
                }
            });
            return chatObjects;
        });
    };

    this.loadSingleChat = function(chatID){
        var _self = this;
        if(chatID){
            this.showLoadingCover();
            return firebase.database().ref('chats/'+chatID).once('value').then(function(snapshot){
                if(!snapshot.exists()){
                    _self.showNotice("Chat Not Found");
                    return;
                }
                var data = snapshot.val();
                data.id = snapshot.key;
                var objects = [data];
                _self.loadChatOpponents(objects).then(function(chatObjects){
                    _self.showChat(chatObjects[0]);
                    _self.hideLoadingCover();
                });
            });
        }else{
            this.showNotice("Chat Not Found");
        }
    };

    this.clickedShowChat = function(event){
        if($(event.target).closest(".exclude-row-click").length){
            return;
        }
        var chat = $(event.currentTarget).data('jsonstring');
        var chatID = $(event.currentTarget).data('id');
        if(chat){
            this.showChat(chat);
        }else if(chatID){
            this.loadSingleChat(chatID);
        }
    }

    this.showChat = function(chat){
        if(chat){
            var modal = this.showModal(chat, "chatmodal");
            var chatPage = new DropletPage();
            chatPage.$table = modal.find("[data-role='messages-table']");
            chatPage.$nextButton = modal.find("[data-role='page-next']");
            chatPage.$previousButton = modal.find("[data-role='page-prev']");
            chatPage.$nextButton.on("click", $.proxy(this.loadNextMessages, this, chat, chatPage));
            chatPage.$previousButton.on("click", $.proxy(this.loadPreviousMessages, this, chat, chatPage));
            chatPage.sortDesc = false;
            _self.loadMessages(chat, chatPage);
        }
    }

    this.loadNextMessages = function(chat, page){
        var _self = this;
        var ref = page.refForNext(firebase.database().ref('/messages/'+chat.id));
        return ref.once('value').then(function(snapshot){
            //var objects = _self.parseObjects(snapshot, page.sortDesc);
            var objects = _self.parseMessages(chat, page.sortDesc, snapshot);
            page.updatePagination(objects);
            _self.displayObjects("messagerow", page, objects);
        });
    }

    this.loadPreviousMessages = function(chat, page){
        var _self = this;
        var ref = page.refForPrev(firebase.database().ref('/messages/'+chat.id));
        return ref.once('value').then(function(snapshot){
            //var objects = _self.parseObjects(snapshot, page.sortDesc);
            var objects = _self.parseMessages(chat, page.sortDesc, snapshot);
            page.updatePagination(objects);
            _self.displayObjects("messagerow", page, objects);
        });
    }

    this.loadMessages = function(chat, page){
        var _self = this;
        var ref = page.initialRef(firebase.database().ref('/messages/'+chat.id));
        return ref.once('value').then(function(snapshot){
            //var objects = _self.parseObjects(snapshot, page.sortDesc);
            var objects = _self.parseMessages(chat, page.sortDesc, snapshot);
            page.updatePagination(objects);
            _self.displayObjects("messagerow", page, objects);
        });
    }

    this.parseMessages = function(chat, sortDesc, snapshot){
        var objects = _self.parseObjects(snapshot, sortDesc);
        var incoming_id = Object.keys(chat.occupants)[0];
        $.each(objects, function(idx, object){
            if(object.sender_id && chat.occupants[object.sender_id]){
                objects[idx].sender = chat.occupants[object.sender_id];
            }
            objects[idx].incoming = (object.sender_id == incoming_id)
        });
        console.log(objects);
        return objects;
    }

    this.showAttachment = function(event){
        var _self = this;
        $element = $(event.currentTarget);
        var ref = $element.data("fullref");
        this.loadImageForRef(ref, function(url){
            _self.showModal({image_src : url}, "attachmentmodal");
        });
    }

    this.deleteChat = function(event){
        $element = $(event.currentTarget);
        var chatID = $element.data("id");
        var occupants = $element.data("occupants");
        //var permanentDelete = $element.data("deleted");

        if(!chatID || chatID.length == 0){
            return;
        }

        this.permanentlyDeleteChat(chatID);

        /*

        if(permanentDelete == true){
            this.permanentlyDeleteChat(chatID);
            return;
        }

        this.showConfirmationDialog(
            "Delete Chat",
            "This chat will be deleted for both users but will still be viewable in the admin panel for your reference.  (To permanently delete, just delete again).",
            "danger",
            "Delete Chat",
            function(modal){
                _self.showLoadingCover(0.6);

                var updates = {};

                var occupantID = Object.keys(occupants)[0];
                $.each(Object.keys(occupants), function(idx, occupantID){
                    updates['/user_chats/'+occupantID+'/'+chatID] = null;
                });
                updates['/chats/'+chatID+'/deleted'] = true;

                firebase.database().ref().update(updates)
                    .then(function(){
                        modal.modal('hide');
                        _self.reloadCurrentChats();
                        _self.showNotice("Chat Deleted");
                    })
                    .catch(function(error){
                        modal.modal('hide');
                        _self.showNotice("Error: "+error.message);
                    });
            },
            function(){
                console.log("Did cancel dialog");
            }
        );*/
    }

    this.permanentlyDeleteChat = function(chatID){
        this.showConfirmationDialog(
            "Delete Chat",
            "Are you sure you want to permanently delete this chat and all messages? <strong>This action cannot be undone!</strong>",
            "danger",
            "Delete Chat",
            function(modal){
                _self.showLoadingCover(0.6);

                console.log("Deleting chat",chatID);

                var updates = {};
                updates['/chats/'+chatID] = null;
                //updates['/messages/'+chatID] = null;

                firebase.database().ref().update(updates)
                    .then(function(){
                        modal.modal('hide');
                        _self.reloadCurrentChats();
                        _self.showNotice("Chat Deleted");
                    })
                    .catch(function(error){
                        modal.modal('hide');
                        _self.showNotice("Error: "+error.message);
                    });
            },
            function(){
                console.log("Did cancel dialog");
            }
        );
    }

    /*
     * Reports Methods
     */

    this.loadReportsPage = function(query){
        _self.updateActiveLink(_self.$reportslink);
        _self.$mainContainer.load("reports.html", function(){
            _self.reportsPage.setTable(_self.$mainContainer.find('[data-role="reports-table"]'));
            _self.reportsPage.configureLimitListener(_self.$mainContainer);

            _self.reportsPage.rowTemplateName = "reportrow";

            _self.reportsPage.$searchField = _self.$mainContainer.find("[data-role='search-field']");
            _self.reportsPage.$searchField.on("blur", $.proxy(_self.searchReports, _self, _self.reportsPage.$searchField));
            _self.reportsPage.$searchField.on("focus", $.proxy(_self.configureSearchInput, _self, _self.reportsPage.$searchField));

            _self.reportsPage.$nextButton = _self.$mainContainer.find('[data-role="page-next"]');
            _self.reportsPage.$previousButton = _self.$mainContainer.find('[data-role="page-prev"]');

            _self.reportsPage.$nextButton.on("click", $.proxy(_self.loadNextReports, _self));
            _self.reportsPage.$previousButton.on("click", $.proxy(_self.loadPreviousReports, _self));

            _self.reportsPage.loadingFnc = $.proxy(_self.loadReports, _self);

            if(query && query.length > 0){
                _self.reportsPage.$searchField.val(query);
                _self.configureSearchTags(_self.reportsPage.$searchField)
                _self.loadReportsForQuery(query);
            }else{
                //_self.loadReports(_self.reportsPage);
                _self.reloadCurrentReports(_self.reportsPage);
            }
        });
    }

    this.viewReports = function(event){
        var $element = $(event.currentTarget);
        var query = $element.data("id");
        if(query && query.length > 0){
            this.hideAllModals();
            this.loadReportsPage(query);
        }
    }

    this.loadNextReports = function(){
        var _self = this;
        if(this.reportsPage.nextKey == null){
            return;
        }
        var ref = firebase.database().ref('/reports_summary');
        ref = this.reportsPage.refForNext(ref);
        return ref.once('value').then($.proxy(_self.loadedReports, _self, _self.reportsPage));
    };

    this.loadPreviousReports = function(){
        var _self = this;
        if(this.reportsPage.prevKey == null){
            return;
        }
        var ref = firebase.database().ref('/reports_summary');
        ref = this.reportsPage.refForPrev(ref);
        return ref.once('value').then($.proxy(_self.loadedReports, _self, _self.reportsPage));
    };

    this.loadReports = function(page){
        var _self = this;

        if(_self.reportsPage.$table){
            _self.reportsPage.$table.removeClass("no-sorting");
        }

        var ref = firebase.database().ref('/reports_summary');
        ref = page.initialRef(ref);
        return ref.once('value').then($.proxy(_self.loadedReports, _self, page));
    };

    this.reloadCurrentReports = function(){
        var _self = this;
        var ref = _self.reportsPage.currentRef;
        if(ref){
            return ref.once('value').then($.proxy(_self.loadedReports, _self, _self.reportsPage));
        }else{
            return this.loadReports(_self.reportsPage);
        }
    }

    this.searchReports = function($searchField, event){
        if(this.configureSearchTags($searchField)){
            var query = $searchField.val();
            this.loadReportsForQuery(query);
        }
    };

    this.loadReportsForQuery = function(query, event){
        var _self = this;

        if(query.length == 0){
            this.loadReports(_self.reportsPage);
            return;
        }

        _self.reportsPage.$table.addClass("no-sorting");
        _self.reportsPage.disablePagination();

        var ref = firebase.database().ref("/reports_summary/"+query);
        return ref.once('value').then(function(snapshot){
            var objects = [];
            if(snapshot.exists()){
                var childData = snapshot.val();
                childData.id = snapshot.key;
                objects.push(childData);
            }
            return _self.loadReportUsers(objects).then(function(reportObjects){
                console.log(reportObjects);
                _self.displayObjects("reportrow", _self.reportsPage, reportObjects);
            });
        });
    };

    this.loadedReports = function(page, snapshot){
        var objects = _self.parseObjects(snapshot, page.sortDesc);
        console.log("Loaded reports", objects);
        page.updatePagination(objects);
        return _self.loadReportUsers(objects).then(function(reportObjects){
            _self.displayObjects(page.rowTemplateName, page, reportObjects);
        });
    };

    this.loadReportUsers = function(objects){
        var promises = [];
        $.each(objects, function(idx, report){
            promises.push(firebase.database().ref("users/"+report.id).once('value'));
        });
        return Promise.all(promises).then(function(results){
            var users = {};
            $.each(results, function(idx, result){
                if(result && result.val()){
                    var user = result.val();
                    user.id = result.key;
                    users[user.id] = user;
                }
            });
            $.each(objects, function(idx, report){
                if(users[report.id]){
                    objects[idx].user = users[report.id];
                }
            });
            return objects;
        });
    };

    this.showReport = function(event){
        if($(event.target).closest(".exclude-row-click").length){
            return;
        }
        var report = $(event.currentTarget).data('jsonstring');
        if(report){
            var modal = this.showModal(report, "reportmodal");
            var reportPage = new DropletPage();
            reportPage.$table = modal.find("[data-role='child-reports-table']");
            reportPage.$nextButton = modal.find("[data-role='page-next']");
            reportPage.$previousButton = modal.find("[data-role='page-prev']");
            reportPage.$nextButton.on("click", $.proxy(this.loadNextChildReports, this, report, reportPage));
            reportPage.$previousButton.on("click", $.proxy(this.loadPreviousChildReports, this, report, reportPage));
            _self.loadChildReports(report, reportPage);
        }
    }

    this.loadNextChildReports = function(report, page){
        var _self = this;
        var ref = page.refForNext(firebase.database().ref('/reports/'+report.id));
        return ref.once('value').then(function(snapshot){
           _self.loadedChildReports(snapshot, page);
        });
    }

    this.loadPreviousChildReports = function(report, page){
        var _self = this;
        var ref = page.refForPrev(firebase.database().ref('/reports/'+report.id));
        return ref.once('value').then(function(snapshot){
            _self.loadedChildReports(snapshot, page);
        });
    }

    this.loadChildReports = function(report, page){
        var _self = this;
        var ref = page.initialRef(firebase.database().ref('/reports/'+report.id));
        return ref.once('value').then(function(snapshot){
            _self.loadedChildReports(snapshot, page);
        });
    }

    this.loadedChildReports = function(snapshot, page){
        var objects = _self.parseObjects(snapshot, page.sortDesc);
        _self.loadChildReportUsers(objects).then(function(reportObjects){
            page.updatePagination(reportObjects);
            _self.displayObjects("childreportrow", page, reportObjects);
        });
    }

    this.loadChildReportUsers = function(objects){
        var promises = [];
        $.each(objects, function(idx, report){
            promises.push(firebase.database().ref("users/"+report.from).once('value'));
        });
        return Promise.all(promises).then(function(results){
            var users = {};
            $.each(results, function(idx, result){
                if(result && result.val()){
                    var user = result.val();
                    user.id = result.key;
                    users[user.id] = user;
                }
            });
            $.each(objects, function(idx, report){
                if(users[report.from]){
                    objects[idx].from = users[report.from];
                }
            });
            return objects;
        });
    }

    this.loadImageForElement = function(element, onComplete){
        var _self = this;
        var ref = $(element).data('ref')
        _self.loadImageForRef(ref, onComplete);
    }

    this.loadImageForRef = function(ref, onComplete){
        var _self = this;
        if(ref){
            if(_self.imageCache[ref]){
                onComplete(_self.imageCache[ref])
            }else{
                firebase.storage().ref(ref).getDownloadURL().then(function(url){
                    //_self.imageCache[ref] = url;
                    _self.addToImageCache(ref, url);
                    onComplete(url);
                }).catch(function(error){
                    console.log("Error loading image:", error);
                });
            }
        }
    };

    this.displayObjects = function(templateName, page, objects){
        var _self = this;
        if(page.$table == null){
            return;
        }
        if(objects.length == page.limit){
            objects.splice(-1, 1);
        }
        page.$table.find("tbody tr").remove();
        var compiledTemplate = Handlebars.getTemplate(templateName);
        $.each(objects, function(idx, object){
            html = $(compiledTemplate(object));
            $.each(html.find('[data-role="image-to-load"]'), function(idx, element){
                _self.loadImageForElement(element, function(url){
                    $(element).attr("src", url);
                });
            });
            page.$table.find("tbody").append(html);
        });
        _self.initTooltips();
    };

    this.attachGlobalListeners = function($element){

        var _self = this;
    
        /*
         * User Actions
         */
        $("body").on("click", "[data-role='view-user']", $.proxy(this.showUser, this));
        $("body").on("click", "[data-role='show-chats']", $.proxy(this.viewChats, this));
        $("body").on("click", "[data-role='show-reports']", $.proxy(this.viewReports, this)); 
        $("body").on("click", "[data-role='create-chat']", $.proxy(this.showCreateChatDialog, this));        
        $("body").on("click", "[data-role='delete-user']", $.proxy(this.deleteUser, this));
        $("body").on("click", "[data-role='enable-user']", $.proxy(this.changeUserEnabled, this, false));
        $("body").on("click", "[data-role='disable-user']", $.proxy(this.changeUserEnabled, this, true));
        $("body").on("click", "[data-role='delete-image']", $.proxy(this.deleteUserImage, this));

        /*
         * Chat Actions
         */
        $("body").on("click", "[data-role='view-chat']", $.proxy(this.clickedShowChat, this));
        $("body").on("click", "[data-role='delete-chat']", $.proxy(this.deleteChat, this));
        $("body").on("click", "[data-role='show-attachment']", $.proxy(this.showAttachment, this));

        /*
         * Report Actions
         */
        $("body").on("click", "[data-role='view-report']", $.proxy(this.showReport, this));

        /*
         * Misc Listeners
         */
        $("body").on("click", "[data-allow-copy='true']", $.proxy(this.copyText, this));
        //Search on pressing 'Enter' key.
        $("body").on("keyup", "[data-role='search-field']", $.proxy(this.searchFieldKeyUp, this));
        //Fix multiple modal windows scroll issue
        $("body").on('hidden.bs.modal', ".modal", this.modalHiddenFix);
    };

    this.parseObjects = function(snapshot, sortDesc){
        var objects = [];
        snapshot.forEach(function(childSnapshot) {
            var childKey = childSnapshot.key;
            if(isObject(childSnapshot.val())){
                var childData = childSnapshot.val();
                childData.id = childKey;
                objects.push(childData);
            }else{
                objects.push(childKey);
            }
        });
        if(sortDesc){
            objects.reverse();
        }
        return objects;
    };

    this.showModal = function(object, templateName){
        var compiledTemplate = Handlebars.getTemplate(templateName);
        var html = compiledTemplate(object); 
        var modal = $(html);
        modal.modal();
        $.each(modal.find('[data-role="image-to-load"]'), function(idx, element){
            _self.loadImageForElement(element, function(url){
                $(element).attr("src", url);
            });
        });
        var slider = modal.find(".user-images-slider");
        if(slider){
            slider.slick({
                dots: true,
                infinite: false,
                slidesToShow: 1,
                slidesToScroll: 1
            });
            modal.on("shown.bs.modal", function(){
                slider.slick('setPosition');
            });
        }
        return modal;
    };

    this.copyText = function(event){
        var $element = $(event.currentTarget);
        var textToCopy = $element.data("copy");
        copyTextToClipboard(textToCopy);
        this.showNotice("User ID Copied");
    };

    this.initTooltips = function(){
        $('[data-toggle="tooltip"]').tooltip({
            container: 'body'
        });
    }

    this.showNotice = function(message){
        this.$notice.html(message);
        this.$notice.addClass('show');
        this.$notice.addClass('showing-notice');
        var _self = this;
        setTimeout(function(){
            _self.$notice.removeClass('show');
            _self.$notice.removeClass('showing-notice');
        }, 3000);
    };

    this.showConfirmationDialog = function(title, body, buttonClass, buttonText, onConfirm, onCancel){
        var compiledTemplate = Handlebars.getTemplate("confirmmodal");
        var html = compiledTemplate({
            'title' : title,
            'body'  : body,
            'primary_button_class' : buttonClass,
            'primary_button' : buttonText
        }); 
        var modal = $(html);
        modal.find("[data-role='primary-button']").on("click", $.proxy(onConfirm, this, modal));
        modal.find("[data-role='cancel-button']").on("click", $.proxy(onCancel, this));
        modal.modal();
        return modal;
    }

    this.showLoadingCover = function(opacity){
        //this.$loadingCover.css('opacity', opacity);
        //this.$loadingCover.show();
        this.$notice.html("<img src='img/ajax-loader-white.gif'>");
        this.$notice.addClass('show');
    }

    this.hideLoadingCover = function(){
        //this.$loadingCover.hide();
        //this.$loadingCover.css('opacity', '1.0');
        this.$notice.removeClass('show');
    }

    this.hideAllModals = function(){
        $('.modal').modal('hide');
    }

    this.searchFieldKeyUp = function(event){
        if (event.keyCode === 13) {
            $(event.currentTarget).blur();
        }
    }

    this.configureSearchTags = function($searchField){
        console.log("Configuring search tags");
        var compiledTemplate = Handlebars.getTemplate("searchtag");
        var query = $searchField.val();
        if(query && query.length > 0){
            var $html = $(compiledTemplate({query : query}));
            console.log("Clear button: ", $(html).find("[data-role='search-clear']"));
            $html.find("[data-role='search-clear']").on("click", $.proxy(this.clearSearch, this, $searchField));
            $html.on("click", function(event){
                if($(event.target).closest("[data-role='search-clear']").length){
                    return;
                }
                $searchField.focus();
            });
            $searchField.next("[data-role='search-tag']").remove();
            $searchField.after($html);
        }
        var initialVal = $searchField.data("initial-value");
        $searchField.data("initial-value", null);
        return (initialVal != $searchField.val());
    };

    this.configureSearchInput = function($searchField){
        var $searchTag = $searchField.next("[data-role='search-tag']");
        var query = $searchTag.find("[data-role='search-value']").text();
        $searchField.val(query);
        $searchTag.remove();
        $searchField.data("initial-value", $searchField.val());
    };

    this.clearSearch = function($searchField, event){
        var $searchTag = $(event.currentTarget).closest("[data-role='search-tag']");
        $searchTag.remove();
        console.log("Clearing the search!", $searchField);
        $searchField.val("");
        $searchField.blur();
    };

    this.modalHiddenFix = function(event){
        if ($('body > .modal.show').length) {
            $("body").addClass("modal-open");
        }
    };
};