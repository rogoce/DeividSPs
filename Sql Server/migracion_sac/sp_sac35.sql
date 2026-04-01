
drop procedure sp_sac35;

create procedure "informix".sp_sac35(a_cuenta char(25))
returning char(25);

define v_cuenta	char(25);

if a_cuenta = "1110206" then

	let v_cuenta = "112010201";	

elif a_cuenta = "1110208" then

	let v_cuenta = "112010202";	

elif a_cuenta = "1110210" then

	let v_cuenta = "111029902";	

elif a_cuenta = "1220204" then

	let v_cuenta = "12202010301";	

elif a_cuenta = "1220205" then

	let v_cuenta = "12202010304";	

elif a_cuenta = "1220206" then

	let v_cuenta = "12202010903";	

elif a_cuenta = "1220207" then

	let v_cuenta = "12202010901";	


elif a_cuenta = "1220208" then

	let v_cuenta = "12202010904";	

elif a_cuenta = "1220211" then

	let v_cuenta = "12202011202";	

elif a_cuenta = "1220214" then

	let v_cuenta = "12202011201";	

elif a_cuenta = "1220215" then

	let v_cuenta = "12202010801";	

elif a_cuenta = "1220216" then

	let v_cuenta = "12202010601";	

elif a_cuenta = "1220210" then

	let v_cuenta = "12202010402";	

elif a_cuenta = "1220217" then

	let v_cuenta = "12202010305";	

elif a_cuenta = "1220218" then

	let v_cuenta = "12202010401";	

elif a_cuenta = "1220219" then

	let v_cuenta = "12202010305";	

elif a_cuenta = "1220220" then

	let v_cuenta = "12202011203";	

elif a_cuenta = "1220221" then

	let v_cuenta = "12202011204";	

elif a_cuenta = "1220225" then

	let v_cuenta = "12202010302";	

elif a_cuenta = "1220227" then

	let v_cuenta = "12202010902";	

elif a_cuenta = "1220228" then

	let v_cuenta = "12202010403";	

elif a_cuenta = "1220229" then

	let v_cuenta = "12202010307";	

elif a_cuenta = "160020001" then

	let v_cuenta = "160020201";	

elif a_cuenta = "160020002" then

	let v_cuenta = "160020301";	

elif a_cuenta = "160020003" then

	let v_cuenta = "160020101";	

elif a_cuenta = "160020004" then

	let v_cuenta = "160020401";	

elif a_cuenta = "18008" then

	let v_cuenta = "18010";	

elif a_cuenta = "18015" then

	let v_cuenta = "18007";	

elif a_cuenta = "18017" then

	let v_cuenta = "18021";	

elif a_cuenta = "601" then

	let v_cuenta = "6000101";	

elif a_cuenta = "602" then

	let v_cuenta = "6000102";	

elif a_cuenta = "603" then

	let v_cuenta = "6000103";	

elif a_cuenta = "604" then

	let v_cuenta = "6000104";	

elif a_cuenta = "605" then

	let v_cuenta = "6000105";	

elif a_cuenta = "606" then

	let v_cuenta = "6000106";	

elif a_cuenta = "607" then

	let v_cuenta = "6000107";	

elif a_cuenta = "608" then

	let v_cuenta = "6000108";	

elif a_cuenta = "609" then

	let v_cuenta = "6000109";	

elif a_cuenta = "612" then

	let v_cuenta = "6000112";	

elif a_cuenta = "620" then

	let v_cuenta = "6000120";	

elif a_cuenta = "621" then

	let v_cuenta = "6000121";	

elif a_cuenta = "622" then

	let v_cuenta = "6000122";	

elif a_cuenta = "623" then

	let v_cuenta = "6000123";	

elif a_cuenta = "624" then

	let v_cuenta = "6000124";	

elif a_cuenta = "625" then

	let v_cuenta = "6000125";	

elif a_cuenta = "626" then

	let v_cuenta = "6000126";	

elif a_cuenta = "627" then

	let v_cuenta = "6000127";	

elif a_cuenta = "628" then

	let v_cuenta = "6000128";	

elif a_cuenta = "629" then

	let v_cuenta = "6000129";	

elif a_cuenta = "630" then

	let v_cuenta = "6000130";	

elif a_cuenta = "631" then

	let v_cuenta = "6000131";	

elif a_cuenta = "632" then

	let v_cuenta = "6000132";	

elif a_cuenta = "633" then

	let v_cuenta = "6000133";	

elif a_cuenta = "634" then

	let v_cuenta = "6000134";	

elif a_cuenta = "635" then

	let v_cuenta = "6000135";	

elif a_cuenta = "636" then

	let v_cuenta = "6000136";	

elif a_cuenta = "637" then

	let v_cuenta = "6000137";	

elif a_cuenta = "638" then

	let v_cuenta = "6000138";	

elif a_cuenta = "660" then

	let v_cuenta = "6000160";	

elif a_cuenta = "661" then

	let v_cuenta = "6000161";	

elif a_cuenta = "662" then

	let v_cuenta = "6000162";	

elif a_cuenta = "663" then

	let v_cuenta = "6000163";	

elif a_cuenta = "664" then

	let v_cuenta = "6000164";	

elif a_cuenta = "665" then

	let v_cuenta = "6000165";	

elif a_cuenta = "666" then

	let v_cuenta = "6000166";	

elif a_cuenta = "680" then

	let v_cuenta = "6000180";	

elif a_cuenta = "682" then

	let v_cuenta = "6000182";	

elif a_cuenta = "683" then

	let v_cuenta = "6000183";	

elif a_cuenta = "684" then

	let v_cuenta = "6000184";	

elif a_cuenta = "685" then

	let v_cuenta = "6000185";	

elif a_cuenta = "1210201" then

	let v_cuenta = "1210202";	

elif a_cuenta = "1220108" then

	let v_cuenta = "1220112";	

elif a_cuenta = "1440103" then

	let v_cuenta = "144020101";	

elif a_cuenta = "1440104" then

	let v_cuenta = "144020102";	

elif a_cuenta = "1440105" then

	let v_cuenta = "144020103";	

elif a_cuenta = "1440109" then

	let v_cuenta = "144020107";	

elif a_cuenta = "1440110" then

	let v_cuenta = "14402010802";	

elif a_cuenta = "1440111" then

	let v_cuenta = "14402010804";	

elif a_cuenta = "1440112" then

	let v_cuenta = "144030104";	

elif a_cuenta = "160020101" then

	let v_cuenta = "160020202";	

elif a_cuenta = "160020102" then

	let v_cuenta = "160020302";	

elif a_cuenta = "160020103" then

	let v_cuenta = "160020102";	

elif a_cuenta = "160020104" then

	let v_cuenta = "160020402";	

elif a_cuenta = "16011" then

	let v_cuenta = "160030101";	

elif a_cuenta = "1601101" then

	let v_cuenta = "160030102";	

elif a_cuenta = "16012" then

	let v_cuenta = "160030301";	

elif a_cuenta = "1601201" then

	let v_cuenta = "160030302";	

elif a_cuenta = "16013" then

	let v_cuenta = "160090101";	

elif a_cuenta = "1601301" then

	let v_cuenta = "160090102";	

elif a_cuenta = "1601401" then

	let v_cuenta = "160080102";	

elif a_cuenta = "18010" then

	let v_cuenta = "18019";	

elif a_cuenta = "21101010402" then

	let v_cuenta = "21101010401";	

elif a_cuenta = "211020109" then

	let v_cuenta = "21102010804";	

elif a_cuenta = "21301010402" then

	let v_cuenta = "21301020401";	

elif a_cuenta = "21302010101" then

	let v_cuenta = "213020101";	

elif a_cuenta = "21302010102" then

	let v_cuenta = "213020102";	

elif a_cuenta = "21302010103" then

	let v_cuenta = "213020103";	

elif a_cuenta = "21302010103" then

	let v_cuenta = "213020104";	

elif a_cuenta = "21302010106" then

	let v_cuenta = "213020106";	

elif a_cuenta = "21302010107" then

	let v_cuenta = "213020107";	

elif a_cuenta = "21302010108" then

	let v_cuenta = "21302010804";	

elif a_cuenta = "21302010109" then

	let v_cuenta = "21302010804";	

elif a_cuenta = "21401010402" then

	let v_cuenta = "21401020401";	

elif a_cuenta = "21402010101" then

	let v_cuenta = "214020101";	

elif a_cuenta = "21402010102" then

	let v_cuenta = "214020102";	

elif a_cuenta = "21402010103" then

	let v_cuenta = "214020103";	

elif a_cuenta = "21402010104" then

	let v_cuenta = "214020104";	

elif a_cuenta = "21402010106" then

	let v_cuenta = "214020106";	

elif a_cuenta = "21402010107" then

	let v_cuenta = "214020107";	

elif a_cuenta = "21402010108" then

	let v_cuenta = "21402010802";	

elif a_cuenta = "21402010109" then

	let v_cuenta = "21402010804";	

elif a_cuenta = "22101010402" then

	let v_cuenta = "22101010401";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	

elif a_cuenta = "" then

	let v_cuenta = "";	
else

	let v_cuenta = a_cuenta;

end if

return v_cuenta;
 
end procedure