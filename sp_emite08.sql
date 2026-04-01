-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 17/05/2019 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite08;

create procedure "informix".sp_emite08() 
returning	smallint,varchar(200);

define _prima_neta_emi 	dec(16,2);
define _prima_neta 		dec(16,2);
define _dif_prima 		dec(16,2);
define _cant_iter 		smallint;
define _cont 				smallint;
define _error           	smallint;
define _no_factura		   	char(10);
define _no_poliza		   	char(10);
define _no_unidad      	char(5);
define _error_desc		varchar(200);
define _error_isam		smallint;
define _error_title		varchar(30);
define _vigencia_inic			date;
define _cnt			smallint;
define v_codcompania		char(3);
define _no_documento		varchar(20);

	begin
	on exception set _error,_error_isam,_error_desc
		return _error,_error_desc;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_emite01.trc"; 
	--trace on;

--begin work;

	let _prima_neta_emi = 0.00;
	let _prima_neta = 0.00;
	let _dif_prima = 0.00;
	let _cant_iter = 0;
	let _cont = 0;
	let v_codcompania = '001';
	let _error_desc = "";   

	foreach
		select no_documento,vigencia_inic,no_factura,count(*)
		  into _no_documento,_vigencia_inic,_no_factura,_cnt
		  from emipomae
		 where no_factura is not null
		  -- and no_factura >= '853518'
		   and no_factura not like '%-%'
		  -- and cod_ramo <> '002'
		   and vigencia_inic >= '01/01/2024'
		   and no_documento in ('0322-02144-01',
'0322-02145-01',
'0394-0130-01',
'0125-07660-01',
'0825-07706-01',
'0125-07779-07',
'2225-07781-05',
'2225-07782-05',
'2225-07785-05',
'0825-07797-01',
'0225-07832-01',
'0125-07834-01',
'0225-07837-01',
'0225-07839-01',
'0125-07844-07',
'0225-07845-01',
'0325-07883-01',
'0125-07894-01',
'0324-05972-01',
'0323-00008-07',
'0315-00135-01',
'0225-07910-01',
'0925-07917-01',
'0125-07930-07',
'0325-07933-07',
'0323-02717-01',
'0925-07935-11',
'0125-07985-01',
'2225-08017-07',
'0125-08038-07',
'0225-08046-01')
		 group by no_documento,vigencia_inic,no_factura
		 having count(*) > 1

		let _error = 0;
		foreach
			select no_poliza
			  into _no_poliza
			  from emipomae
			 where actualizado = 0
			   and no_factura is not null
			   --and no_factura >= '853518'
			   and no_factura not like '%-%'
			   and no_documento = _no_documento
			   and no_poliza not in ('3119386',
'3119387',
'3098353',
'3098355',
'3098371',
'3120087',
'3153408',
'3121094',
'3121132',
'3103353',
'3107576',
'3114103',
'3115064',
'3115067',
'3115069',
'0003115401',
'3129233',
'3129708',
'3134760',
'3135529',
'3135533',
'3138199',
'3149555',
'3152224')

			call sp_sis61b(_no_poliza) returning _error,_error_desc;
		end foreach 

		if _error <> 0 then
			return _error,_error_desc with resume;
		else
			return 0,"Actualización Exitosa: "|| _no_documento with resume;
		end if
	end foreach	
	
	end
end procedure;
