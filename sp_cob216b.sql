-- Creacion de endosos de pronto pago electronico resagados por cualquier causa
-- Creado    : 24/01/2014 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cob216b;

create procedure "informix".sp_cob216b(a_no_poliza char(10))
returning char(10),char(20),char(100),dec(16,2),char(8);

define _no_poliza			char(10);
define _monto_desc	     	dec(16,2);
define _usuario             char(8);
DEFINE _error     	    	SMALLINT;
DEFINE _mensaje  			CHAR(30);
define v_cod_contratante    char(10);
define v_no_doc             char(20);
define v_nom_cont           varchar(100);



begin

set isolation to dirty read;

let _error = 0;

foreach
	select no_poliza,
	       monto_descuento,
		   user_added
	  into _no_poliza,
	       _monto_desc,
		   _usuario
	  from cobpronde
	 where procesado = 0
	   and no_poliza = a_no_poliza

   select cod_contratante,
          no_documento
     into v_cod_contratante,
	      v_no_doc
	 from emipomae
	where no_poliza = _no_poliza;


	select nombre
	  into v_nom_cont
	  from cliclien
	 where cod_cliente = v_cod_contratante;

	return _no_poliza,
		   v_no_doc,
		   v_nom_cont,
		   _monto_desc,
		   _usuario with resume;


	call sp_pro862b(_no_poliza, _usuario, _monto_desc) returning _error, _mensaje; -- creacion del endoso de pronto pago

	if _error = 0 then
		update cobpronde
		   set procesado = 1
		 where no_poliza = _no_poliza;
	end if

end foreach
end
end procedure;