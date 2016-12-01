function zoomIn(x)
{
    
        var fontsize;
        switch(x)
        {
                    case 0:
                        fontsize = "1em";
                        break;
                    case 1:
                        fontsize = "1.2em";
                        break;
                    case 2:
                        fontsize = "1.4em";
                        break;
                    case 3:
                        fontsize = "1.6em";
                        break;
                    case 4:
                        fontsize = "1.8em";
                        break;
                    default:
                        fontsize = "1em";
    }
    
        document.body.style.fontSize = fontsize;


    /*
    var z = 1+(x*0.2);
    if(z > 1.8) {
    
        	z=1.8;
        	return z;
    }
    document.body.style.zoom = z;
    return z;
     
     */
}

/* Only set closed if JS-enabled */
document.getElementsByTagName('html')[0].className = 'isJS';
function tog(currentTag) {
var display;
var currParent = currentTag.parentNode;
var currParentParent = currParent.parentNode;
var tag2collapse = currParentParent.getElementsByTagName('div')[1];
toOpen = !tag2collapse.style.display;
tag2collapse.style.display = toOpen ? 'block' : ''
currentTag.getElementsByTagName('span')[0].innerHTML = toOpen ? '-' : '+';
}
var lastDivID;
function showPopup(divid){
if (lastDivID!=null){
var lstmsgbox = document.getElementById(lastDivID);
lstmsgbox.style.display = 'none';
}
var msgbox = document.getElementById(divid);
msgbox.style.display = 'block';
lastDivID=divid;
}
function hideAnchorlinks()
{
    var elements = document.getElementsByTagName('a');
    
    for(var i=0; i<elements.length; i++){
        var str = elements[i].href;
        var fileExt = str.split('.').pop();
        /* use this condition because of in lancet journals tables come as image and show in anchor. So when hide all anchors images also hide*/
        if((fileExt != 'gif') && (fileExt != 'png'))
            elements[i].style.color = '#333333';
        elements[i].href = null;
    }

}

function showTableCSS(){

    var elements = document.getElementsByClassName('tblbor2');
    var count = elements.length;
    for(var i=count-1; i>=0; i--){
       elements[i].className = 'tblbor';
    }
}


function changeNotesIconCSS(){
    
    var elements = document.getElementsByClassName('NotesImage');
    var count = elements.length;
    for(var i=count-1; i>=0; i--){
        elements[i].style.position = 'relative';
        elements[i].style.marginRight= '32px';
    }
}
function changeNotesIconImage(imageName){
    
    var elements = document.getElementsByClassName('NotesImage');
    var count = elements.length;
    for(var i=count-1; i>=0; i--){
        elements[i].src = imageName;
    }
}

