myApp.controller('CommentatorCtrl', function ($scope, $modalInstance, $http, art, user, row, comment) {
    $scope.art = art;
    $scope.user = user;
    $scope.row = row;
    $scope.comment = comment;
    if (!$scope.comment.content) {
        $scope.comment.content = {};
    }
    if (!$scope.comment.content[row]) {
        $scope.comment.content[row] = {txt:""};
    }
    $scope.txt = $scope.comment.content[row].txt;

    function reportError(data) {
        console.log("ERROR", data);
    }
    function getComments() {
        var getURL = "ds/d="+$scope.art+"/AllComments";
        $http.get(getURL)
        .then( function(data) {
                console.log("getComments RECEIVED", data);
                $scope.allComments = data.data;
                $scope.commenters = Object.keys($scope.allComments);
            },
            function(data, status, headers, config) {
                reportError(data);
            });
    }
    function saveComment() {
        comment.content[row].txt = $scope.txt;
        var getURL = "ds/d="+$scope.art+"/MakeComment";
        var commentMaker = {user: $scope.user, row: $scope.row, text: $scope.txt};
        
        var postdata = angular.toJson(commentMaker);
        $http.post(getURL, postdata)
        .then( function(data) {
                $modalInstance.close(data.data);
            },
            function(data, status, headers, config) {
                reportError(data);
            });
    }

    $scope.ok = function () {
        saveComment();
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };

    $scope.truncate = function () {
        $scope.txt = $scope.txt.substring(0,500);
    };
    
});