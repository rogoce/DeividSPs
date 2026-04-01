----------------------------------------------------------
--Proceso de Pre-Renovaciones
--Creado    : 02/02/2016 - Autor: Román Gordón
----------------------------------------------------------

--execute procedure sp_pro381('001','001','2016-02','2016-02','*','002,020,023;','*','*','*','*',0,'*','*',0,'*','*','*')
drop procedure sp_pro381d;
create procedure sp_pro381d(a_no_poliza CHAR(10)) RETURNING integer as error_r;

DEFINE _no_poliza_ant 	CHAR(10);
DEFINE _saldo 			DEC(16,2);
DEFINE _prima_bruta 	DEC(16,2);
DEFINE _diezporc		DEC(16,2);
DEFINE _error			integer;
DEFINE _error_isam		integer;
DEFINE _error_desc 		varchar(100);       

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	return _error;
end exception

	LET _no_poliza_ant = NULL;

	SELECT distinct no_poliza_ant 
	  INTO _no_poliza_ant
	  FROM prdpreren
	 WHERE no_poliza_r = a_no_poliza;
	 
	IF _no_poliza_ant IS NOT NULL AND TRIM(_no_poliza_ant) <> "" THEN
		SELECT saldo
		  INTO _saldo
		  FROM emipomae
		 WHERE no_poliza = _no_poliza_ant;
		 
		SELECT prima_bruta
          INTO _prima_bruta
		  FROM emipomae
		 WHERE no_poliza = a_no_poliza;
		 
		let _diezporc = 0;
		
		let _diezporc = _prima_bruta * 0.10;	

		--Solo pólizas con saldo <= al 10% de la prima
		if _saldo > _diezporc then		
			RETURN 344;
		end if		
		 
	END IF
    
	RETURN 0;
end
end procedure;