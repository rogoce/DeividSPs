-- Procedimiento que envia atributo de endoso
-- Creado    : 20/04/2017 - Autor: Henry Giron
drop procedure sp_log026;

create procedure sp_log026(a_no_poliza char(10), a_no_endoso char(10), a_user char(10), a_tipo smallint)
returning smallint,
          char(50);

define _no_documento		char(20);
define _cod_contratante 	char(10);	 
define _cantidad			smallint;
define _interna		    	smallint;
define _cod_endomov     	char(3);
define _cod_tipocan     	char(3);
define _status       	    char(1);

define _error				smallint;
define _error_isam			smallint;
define _error_desc			char(50);

define _flag1				smallint;
define _mensaje			    char(50);

define _realiza_imp			smallint;
define _count				smallint;		
define _tipo				smallint;		

--set debug file to "sp_log026.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception
end		

let _flag1 = 0;
let _tipo = 0;
let _mensaje = "";

select interna,
	   cod_endomov,
	   cod_tipocan,
	   no_documento,
	   actualizado
  into _interna,
	   _cod_endomov,
	   _cod_tipocan,
	   _no_documento,
	   _status
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _status = '1' then 
	CALL sp_log021(a_no_poliza,a_no_endoso,a_user) returning _flag1,_mensaje; 
	  
	 if _flag1 <> 0 then 
		let _realiza_imp = 1;
		let _count = 0;
			select count(*)
			  into _count
			  from endpool0 
			 where no_poliza = a_no_poliza 
			   and no_endoso = a_no_endoso;
			  
			  if _count > 0 then								
				delete from endpool0 
				      where  no_poliza = a_no_poliza 
					    and no_endoso = a_no_endoso; 
			end if
	else
		CALL sp_log024(a_no_poliza,a_no_endoso,a_user) returning _flag1,_mensaje; 
		  
		 if _flag1 <> 0 then 
			let _realiza_imp = 1;
			let _tipo = 1;
			CALL sp_log023(a_no_poliza,a_no_endoso,a_user,_tipo) returning _flag1,_mensaje; 																
		else								  
			let _realiza_imp = 0;
		end if
		
	end if							
end if
								
return _realiza_imp,_mensaje;

--HG:20170412 se imprime solo sucursales, siempre va al pool para impresion de acreedores y completos
--if	li_realiza_imp = 0  then
--	MessageBox("Advertencia","La Poliza: " + ls_doc_poliza+" se va al Pool de Endoso.",Information! ) 
--	return 
--else
--end if

end procedure


