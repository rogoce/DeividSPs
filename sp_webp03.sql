-- Reporte de Clientes con años sin actualizar la ponderación

-- Creado    : 26/11/2024 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_webp03;

create procedure sp_webp03(agnos int, opcion char(1))
returning char(10)			as cod_cliente,
		  dec(16,2)			as ponderacion,
		  char(50)			as riesgo,
		  date				as fecha_registro,
		  date				as fecha_actualizo,
		  char(8)			as usuario_pondero,
		  char(8)			as usuario_modifico,
		  date				as fecha_comparar,
		  varchar(150)      as nombre_cliente,
		  char(30)          as cedula,
		  date				as fecha_creacion,
		  char(8)           as usuario_creo,
		  varchar(100)      as nombre_ramo,
		  date				as fecha_suscripcion,
		  char(8)			as usuario_actualizo,
		  date				as fecha_emision,
		  varchar(100)		as ramo_renovado,
		  date              as fecha_renovado;

define _cod_cliente				char(10);			
define _valor_ponderacion		dec(16,2);
define _cod_riesgo				smallint;
define _date_add				date;
define _date_changed			date;
define _user_add				char(8);
define _user_changed			char(8);
define _fecha_compara			date;
define _nombre_cliente			varchar(150);
define _cedula					char(30);
define _date_added				date;
define _user_added				char(8);
define _nombre_riesgo           char(50);
define _nombre_ramo				varchar(100);
define _fecha_suscripcion       date;
define _user_added_emi   		char(8);
define _fecha_emision			date;
define _nombre_ramor			varchar(100); 
define _fecha_suscripcionr		date; 
define _no_documento            varchar(20);
define _nueva_renov             char(1);


{if a_no_reclamo = '18-0919-13297-01' then
	set debug file to "sp_rec83.trc";
	trace on;
end if }

set isolation to dirty read;

let _nombre_ramor 		= ""; 
let _fecha_suscripcionr = "";
let _fecha_emision      = "";
let _user_added_emi     = "";
let _nombre_ramo		= "";
let _fecha_suscripcion  = ""; 
let _user_added_emi     = ""; 
let _fecha_emision      = "";
let _nombre_ramor       = "";   
let _fecha_suscripcionr = "";

foreach
	SELECT a.cod_cliente,
		   a.valor_ponderacion,
		   a.cod_riesgo,
		   a.date_add,
		   a.date_changed,
		   a.user_add,
		   a.user_changed,
		   CASE
			WHEN a.date_changed > a.date_add THEN a.date_changed
			ELSE a.date_add
		   END AS fecha_compara
	  into _cod_cliente,
	       _valor_ponderacion,
		   _cod_riesgo,
		   _date_add,
		   _date_changed,
		   _user_add,
		   _user_changed,
		   _fecha_compara
	  FROM ponderacion a inner join emipomae b on b.cod_contratante = a.cod_cliente
	 WHERE sp_sis78(CASE WHEN a.date_changed > a.date_add THEN a.date_changed ELSE a.date_add END, today) = agnos and estatus_poliza = 1
	 group by 1,2,3,4,5,6,7,8
	   
    foreach
		   select nombre, fecha_suscripcion, user_added, fecha_impresion
			 into _nombre_ramo, _fecha_suscripcion, _user_added_emi, _fecha_emision
			 from emipomae a inner join prdramo b on a.cod_ramo = b.cod_ramo
			where cod_contratante = _cod_cliente 
			  and actualizado = 1
			  and nueva_renov = 'N'
		 order by fecha_suscripcion desc
		exit foreach;
	end foreach
	foreach
		   select nombre, fecha_suscripcion
			 into _nombre_ramor, _fecha_suscripcionr
			 from emipomae a inner join prdramo b on a.cod_ramo = b.cod_ramo
			where cod_contratante = _cod_cliente 
			  and actualizado = 1
			  and nueva_renov = 'R'
		 order by fecha_suscripcion desc
		exit foreach;
	end foreach
		
	select nombre,
		   cedula,
		   date_added,
		   user_added
	  into _nombre_cliente,
	       _cedula,
		   _date_added,
		   _user_added		   
	  from cliclien
	 where cod_cliente = _cod_cliente;
	 
	 select nombre
	   into _nombre_riesgo
	   from cliriesgo
	   where cod_riesgo = _cod_riesgo;	
		
			return _cod_cliente,
			       _valor_ponderacion,
			       _nombre_riesgo,
			       _date_add,
			       _date_changed,
			       _user_add,
			       _user_changed,
			       _fecha_compara,
				   _nombre_cliente,	
				   _cedula,			
				   _date_added,		
				   _user_added, 
				   _nombre_ramo, 
				   _fecha_suscripcion, 
				   _user_added_emi, 
				   _fecha_emision,
				   _nombre_ramor, 
				   _fecha_suscripcionr
				   with resume;
end foreach

end procedure;