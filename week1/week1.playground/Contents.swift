func checkWeekdayEmoji(i: Int) {
    
    if i % 7 == 1{
        print("Monday😩")
    }else if i % 7 == 2{
        print("Tuesday☹️")
    }else if i % 7 == 3{
        print("Wednesday🙁")
    }else if i % 7 == 4{
        print("Thursday😕")
    }else if i % 7 == 5{
        print("Friday🙂")
    }else if i % 7 == 6{
        print( "Saturday😄")
    }else if i % 7 == 0{
        print( "Sunday🥹")
    }
}

checkWeekdayEmoji(i:12)
