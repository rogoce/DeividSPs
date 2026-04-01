-- pool impresion de renovacion automatica
-- Creado		: 18/05/2009	- Autor: Henry Giron.
-- Modifciado	: 07/02/2012	- Autor: Roman Gordon	**Se Agrego al acreedor para aplicarlo al ordenamiento del datawindow
-- Modifciado	: 04/12/2012	- Autor: Roman Gordon	**Se Agrego el campo de leasing 

drop procedure sp_log020em0;


create procedure "informix".sp_log020em0(a_sucursal char(350), a_estatus smallint,a_desde date,a_hasta date)
	returning 	varchar(50) as nom_acreedor,
				char(5) as cod_acreedor,
				varchar(100) as email;

define _nom_acreedor		varchar(50);
define _cod_acreedor		char(5);
define _email       	    varchar(100);
define v_filtros       	    varchar(255);
define _descripcion			varchar(30);
define _error				smallint;
define _cnt                 smallint;

call sp_log020em(a_sucursal, a_estatus ,a_desde,a_hasta) returning v_filtros;

set isolation to dirty read;

--set debug file to "sp_log020em0.trc";
--trace on;

foreach
select distinct nom_acreedor,
		cod_acreedor,
		email
	into _nom_acreedor,
		_cod_acreedor,
		_email
	from temp_acreedor		
	order by nom_acreedor	
		
	if _cod_acreedor is null then
		continue foreach; --return 0,'';  -- condicion de si no esta completo con el correo no se envia. JEPEREZ 01/10/2020.
	end if

	let _cnt = 0;
	select count(*)
	  into _cnt
	  from emiacre
	 where activo = 1 and email is not null
	   and cod_acreedor = _cod_acreedor;

	if _cnt is null then
		let _cnt = 0;
	end if
	   
	if _cnt = 0 then
		continue foreach; --return 0,'';  -- condicion de si no esta completo con el correo no se envia. JEPEREZ 01/10/2020.
	end if      

	call sp_log033e('00045',_cod_acreedor,_email ,a_desde,a_hasta) returning _error, _descripcion;			
	
		return  _nom_acreedor,
			_cod_acreedor,
			_email			
			with resume;
end foreach


end procedure	
                                                                                                                                                                                                                                                            
