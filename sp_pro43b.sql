-- Procedure extencion del sp_pro43

-- Creado: 02/06/2011 - Autor: Amado Perez Mendoza 

drop procedure sp_pro43b;

create procedure "informix".sp_pro43b(a_no_poliza CHAR(10), a_no_endoso CHAR(5), a_opcion SMALLINT) 
returning SMALLINT, CHAR(100);

define _cnt_leasing	     smallint;
define _cnt_acree	     smallint;
define _mensaje          char(100);

set isolation to dirty read;

IF a_opcion = 1 THEN
    LET _cnt_leasing = 0;
    LET _cnt_acree = 0;

	select leasing
      into _cnt_leasing
	  from emipomae
	 where no_poliza = a_no_poliza;

		select count(*)	
		  into _cnt_acree
		  from emipoacr 
		 where no_poliza = a_no_poliza;

		IF _cnt_acree > 0 THEN
	   		LET _mensaje = 'Poliza tiene Acreedor, ya le envio la Carta de Cancelacion?...';
	   		RETURN 1, _mensaje;
		END IF

		IF _cnt_leasing = 1 THEN
	   		LET _mensaje = 'Poliza tiene Leasing, ya le envio la Carta de Cancelacion?...';
	   		RETURN 1, _mensaje;
		END IF
END IF
RETURN 0, NULL;
end procedure