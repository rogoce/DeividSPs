-- Procedimiento de Talkata Ricardo Perez
 
-- Creado     :	13/01/2022 - Autor: Amado

-- SIS v.2.0 - DEIVID, S.A.

drop procedure ap_takata;		

create procedure "informix".ap_takata()
returning varchar(30) as vin,
		  varchar(10) as placa,
		  integer     as ano_auto,
		  varchar(50) as modelo,
		  varchar(20) as poliza,
		  varchar(5)  as unidad,
		  varchar(10) as cod_cliente,
		  varchar(100) as cliente,
		  varchar(50) as e_mail,
		  smallint as perdida;

define _vin		varchar(30);
define _placa	varchar(10);
define _ano_auto	integer;
define _modelo	varchar(50);
define _no_documento	varchar(20);
define _no_unidad	varchar(5);
define _cod_cliente	varchar(10);
define _nombre	varchar(100);
define _e_mail	varchar(50);
define _cnt_perdida smallint;

define _no_poliza char(10);
define _no_motor  char(30);



set isolation to dirty read;

foreach
  SELECT distinct tmp_takata.vin,
         emivehic.placa,   
         emivehic.ano_auto,   
         emimodel.nombre,
         endedmae.no_documento,   
         endeduni.no_unidad,   
         endeduni.cod_cliente,   
         cliclien.nombre,
         cliclien.e_mail,
		 emivehic.no_motor
	INTO _vin,
         _placa,   
         _ano_auto,   
         _modelo,
         _no_documento,   
         _no_unidad,   
         _cod_cliente,   
         _nombre,
         _e_mail,
		 _no_motor
   FROM endmoaut,   
         emivehic,  
         emimodel, 
         endeduni,   
         endedmae,   
         tmp_takata,   
         cliclien  
   WHERE ( emivehic.no_motor = endmoaut.no_motor ) and  
         ( endeduni.no_poliza = endmoaut.no_poliza ) and  
         ( endeduni.no_endoso = endmoaut.no_endoso ) and  
         ( endeduni.no_unidad = endmoaut.no_unidad ) and  
         ( endedmae.no_poliza = endeduni.no_poliza ) and  
         ( endedmae.no_endoso = endeduni.no_endoso ) and  
         ( emivehic.vin = tmp_takata.vin ) and  
         ( emivehic.cod_modelo = emimodel.cod_modelo ) and  
         ( endeduni.cod_cliente = cliclien.cod_cliente ) and
         ( endedmae.actualizado = 1)   
		 
	let _cnt_perdida = 0;	 

    select count(*)
	  into _cnt_perdida
	  from recrcmae
	 where no_motor = _no_motor
       and perd_total = 1 
	   and actualizado = 1;
	
    if _cnt_perdida is null THEN
		let _cnt_perdida = 0;
	end if
	
	if _cnt_perdida > 0 THEN
		let _cnt_perdida = 1;
	end if
    
	return _vin,
	       _placa,   
           _ano_auto,   
           _modelo,
           _no_documento,   
           _no_unidad,   
           _cod_cliente,   
           _nombre,
           _e_mail,
		   _cnt_perdida with resume;
	   
end foreach

end procedure
