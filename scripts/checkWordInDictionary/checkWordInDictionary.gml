function checkWordInDictionary(){

}



// @param arr - the array
// @param value - the value we are looking for
// @param _left - start of the (sub)array
// @param _right - end of the (sub)array
// arr[_left ... _right]


function binarySearch (arr, value, _left, _right)
{
    //end condition
    if(_right >= _left)
    {
        var _mid = _left + (_right - 1) / 2;  //find the middle of this array
        
        if(arr[_mid] == value) //we already found the value
        {
            return true;
        }
        
        //the value in the middle is bigger, so the value can only be on the left side
        //every value on the right side is bigger than the middle, so it can't be there
        if(arr[_mid] > x)
        {
            //split it into a sub array arr[_left ... mid-1]
            //mid is already checked and it was not the value we are looking for
            //check the sub array
            return binarySearch (arr, value, _left, mid-1) //is recursion even possible? Hope so
        }
        
        //the value in the middle is smaller,so it can only be on the right side
        if(arr[_mid] < x)
        {
            return binarySearch (arr, value, mid+1, _right) //same as for left, just the right side this time
        }
    }
    //we can't search anymore, so the value was not in the array
    return false;
}

