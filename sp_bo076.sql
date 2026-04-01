-- Procedure que carga la tabla de tiempos para BO

-- Creado    : 04/01/2011 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo076;

create procedure sp_bo076()
returning integer,
		  date,
		  char(11),
		  smallint,
		  char(2),
		  char(2),
		  char(7),
		  char(11),
		  char(15),
		  char(6),
		  char(7),
		  char(7),
		  char(7),
		  char(7),
		  char(7);

define _id_tiempo			integer;
define _fecha				date;
define _fecha_s				char(11);
define _ano					smallint;
define _mes					char(2);
define _dia					char(2);
define _periodo				char(7);
define _trimestre			char(11);
define _desc_mes			char(15);
define _desc_corta_mes		char(6);
define _periodo_ini_roll12	char(7);
define _periodo_ini_roll18	char(7);
define _periodo_ini_roll24	char(7);
define _periodo_ini_roll30	char(7);
define _periodo_ini_roll36	char(7);

define _j 			smallint;
define _fecha_roll	date;

let _dia = "01";

delete from deivid_bo:dim_tiempo
 where periodo >= "2021-01";

for _ano = 2021 to 2030

	for _j = 1 to 12

		if _j < 10 then
			let _mes = "0" || _j;
		else
			let _mes = _j;
		end if	
		
		let _id_tiempo 	= _ano || _mes || _dia;
		let _fecha		= mdy(_mes, _dia, _ano);
		let _fecha_s	= _ano || "-" || _mes || "-" || _dia;
		let _periodo	= _ano || "-" || _mes;

		if _j >= 1 and _j <= 3 then
			let _trimestre = "Trimestre 1";
		elif _j >= 4 and _j <= 6 then
			let _trimestre = "Trimestre 2";
		elif _j >= 7 and _j <= 9 then
			let _trimestre = "Trimestre 3";
		elif _j >= 10 and _j <= 12 then
			let _trimestre = "Trimestre 4";
		end if 
		
		let _desc_mes			= lower(sp_sac18(_j));
		let _desc_mes           = upper(_desc_mes[1,1]) || _desc_mes[2,15];
		
		let _desc_mes			= _mes || "." || trim(_desc_mes);
		let _desc_corta_mes		= _desc_mes;

		let _fecha_roll     	= _fecha - 11 units month;
		let _periodo_ini_roll12	= sp_sis39(_fecha_roll); 	
			
		let _fecha_roll     	= _fecha - 17 units month;
		let _periodo_ini_roll18	= sp_sis39(_fecha_roll); 	

		let _fecha_roll     	= _fecha - 23 units month;
		let _periodo_ini_roll24	= sp_sis39(_fecha_roll); 	

		let _fecha_roll     	= _fecha - 29 units month;
		let _periodo_ini_roll30	= sp_sis39(_fecha_roll); 	

		let _fecha_roll     	= _fecha - 35 units month;
		let _periodo_ini_roll36	= sp_sis39(_fecha_roll); 	

		insert into deivid_bo:dim_tiempo
		values ( _id_tiempo,			
				 _fecha,				
				 _fecha_s,			
				 _ano,				
				 _mes,				
				 _dia,				
				 _periodo,			
				 _trimestre,			
				 _desc_mes,			
				 _desc_corta_mes,		
				 _periodo_ini_roll12,
				 _periodo_ini_roll18,
				 _periodo_ini_roll24,
				 _periodo_ini_roll30,
				 _periodo_ini_roll36
		       );

		return _id_tiempo,			
			   _fecha,				
			   _fecha_s,				
			   _ano,					
			   _mes,					
			   _dia,					
			   _periodo,				
			   _trimestre,			
			   _desc_mes,			
			   _desc_corta_mes,		
			   _periodo_ini_roll12,
			   _periodo_ini_roll18,
			   _periodo_ini_roll24,
			   _periodo_ini_roll30,
			   _periodo_ini_roll36
			   with resume;

	end for

end for

end procedure
