-- Procedimiento que Html Body funcion javascript para formato currency, separador de miles
-- Pago de reclamos por cheques
-- Creado : 29/05/2018 - Autor: Amado Perez 
Drop procedure sp_html01; 
CREATE PROCEDURE "informix".sp_html01() returning Lvarchar(max); 

Define _html_body1	 Lvarchar(max); -- char(512); 

Let  _html_body1 = '';
	  
let  _html_body1 = trim(_html_body1) ||'<script language="JavaScript">';
let  _html_body1 = trim(_html_body1) ||'function formato(num)';
let  _html_body1 = trim(_html_body1) ||'{';
let  _html_body1 = trim(_html_body1) ||"if (!num || num == 'NaN') return '-';";
let  _html_body1 = trim(_html_body1) ||"num = num.toString().replace(/\$|\,/g,'');";
let  _html_body1 = trim(_html_body1) ||'if (isNaN(num))';
let  _html_body1 = trim(_html_body1) ||'var sign = (num == (num = Math.abs(num)));';
let  _html_body1 = trim(_html_body1) ||'num = Math.floor(num * 100 + 0.50000000001);';
let  _html_body1 = trim(_html_body1) ||'var cents = num % 100;';
let  _html_body1 = trim(_html_body1) ||'num = Math.floor(num / 100).toString();';
let  _html_body1 = trim(_html_body1) ||'if (cents < 10)';
let  _html_body1 = trim(_html_body1) ||'cents = "0" + cents;';
let  _html_body1 = trim(_html_body1) ||'for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3) ; i++)';
let  _html_body1 = trim(_html_body1) ||'{';
let  _html_body1 = trim(_html_body1) ||"num = num.substring(0, num.length - (4 * i + 3)) + ',' + num.substring(num.length - (4 * i + 3));";
let  _html_body1 = trim(_html_body1) ||"}";
let  _html_body1 = trim(_html_body1) ||"document.getElementById('resul').innerHTML = 'B/.' + num + '.' + cents;";
let  _html_body1 = trim(_html_body1) ||'}';
Let  _html_body1 = trim(_html_body1) ||'</script>';		

return _html_body1;

--trace off;
END PROCEDURE



