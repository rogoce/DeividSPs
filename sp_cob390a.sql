-- Carga de Pólizas a la campaña de transición del proceso anulación automático
-- Creado    : 05/12/2016 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob390a;
create procedure 'informix'.sp_cob390a() 
returning	smallint,
			varchar(100);

define _error_desc			varchar(100);
define _nom_gestion			varchar(50);
define _no_documento		char(18);
define _cod_cliente			char(10);
define _cod_campana			char(10);
define _no_poliza			char(10);
define _user_added			char(8);
define _cod_grupo			char(5);
define _sus_gest_automatic	char(3);
define _cod_gestion			char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _estatus_poliza		char(1);
define _monto_pagado		dec(16,2);
define _monto_pag		    dec(16,2);
define _a_pagar				dec(16,2);
define _cnt_cascliente		smallint;
define _cnt_caspoliza		smallint;
define _declarativa			smallint;
define _tipo_aviso			smallint;
define _cnt_poliza			smallint;
define _dia_cobro1			smallint;
define _dia_cobro2			smallint;
define _cnt_delete			smallint;
define _fronting			smallint;
define _pagada				smallint;
define _flag				smallint;
define _error_code			integer;
define _error_isam			integer;
define _renglon				integer;
define _nueva_renov			char(1);
define _no_remesa		    char(10);
define _fecha_remesa	    date;
define _vigencia_inic		date;
define _vigencia_fin		date;
define _cnt_polpag			smallint;

set isolation to dirty read;

--set debug file to 'sp_cob390a.trc';
--trace on ;

begin

on exception set _error_code, _error_isam, _error_desc
 	return _error_code, _error_desc;
end exception

let _cnt_delete = 0;
let _tipo_aviso = 20; -- Gestión Automática
let _pagada = 0;
select valor_parametro
  into _user_added
  from inspaag
 where codigo_parametro = 'user_automatico';


select valor_parametro
  into _sus_gest_automatic
  from inspaag
 where codigo_parametro = 'sus_gest_automatic';

select cod_gestion || ' - ' || trim(nombre)
  into _nom_gestion
  from cobcages
 where cod_gestion = _sus_gest_automatic;

foreach
	select cod_campana,
		   cod_cliente,
		   no_documento   
	  into _cod_campana,
		   _cod_cliente,
		   _no_documento
	  from caspoliza
	 where cod_campana in (select cod_campana from cascampana where tipo_campana = 3)

	let _no_poliza = sp_sis21(_no_documento);

	select cod_ramo,
		   cod_subramo,
		   estatus_poliza,
		   declarativa,
		   cod_grupo,
		   fronting,
		   nueva_renov,
		   vigencia_inic,
		   vigencia_final
	  into _cod_ramo,
		   _cod_subramo,
		   _estatus_poliza,
		   _declarativa,
		   _cod_grupo,
		   _fronting,
		   _nueva_renov,
		   _vigencia_inic,
		   _vigencia_fin
	  from emipomae
	 where no_poliza = _no_poliza;

	let _flag = 0;
	
	call sp_ley003(_no_documento,1) returning _flag,_error_desc;

	{if _estatus_poliza in (2,3,4) then
		let _flag = 1;
	end if

	if _cod_grupo in ('00087','1090','1009','1091') then
		let _flag = 2;
	end if

	if _fronting = 1 then
		let _flag = 3;
	end if
	
	if _cod_ramo = '009' and _declarativa = 1 then
		let _flag = 4;
	end if

	if _cod_ramo in ('014') then
		let _flag = 6;
	elif _cod_ramo in ('016') and _cod_subramo = '007' then
		let _flag = 6;
	end if}
	if _flag < 0 then
		return _flag,_error_desc;
	elif _flag > 0 then
		select count(*)
		  into _cnt_poliza
		  from caspoliza
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_cliente;

		if _cnt_poliza is null then
			let _cnt_poliza = 0;
		end if

		if _cnt_poliza = 0 then
			delete from cascliente
			 where cod_campana = _cod_campana
			   and cod_cliente = _cod_cliente;
		end if

		delete from caspoliza
		 where cod_campana = _cod_campana
		   and no_documento = _no_documento;

		--return _flag, 'Excepción' with resume;
		let _cnt_delete = _cnt_delete + 1;
		continue foreach;
	end if

	let _pagada = 0;

	select pagada
	  into _pagada
	  from emiletra
	 where no_poliza = _no_poliza
	   and no_letra = 1;

	if _pagada is null then
		let _pagada = 0;
	end if
	
	if _pagada = 0 then	 --SD#7592 ENILDA 09/09/2023 revalidacion Emiletra
		if _nueva_renov = 'R' then
			let _monto_pag = 0;
			
			select sum(monto_pag)
			  into _monto_pag
			  from emiletra
			 where no_poliza = _no_poliza;
			
			if _monto_pag > 0 then
				let _pagada = 1 ;
			end if	
		end if
		
		if _cod_grupo = '00068' then  --SD#8393 ENILDA 16/11/2023 Emiletra cero serafin niño
			let _cnt_polpag = 0;
			select count(*)
			  into _cnt_polpag	
			  from cobremae m, cobredet d
			 where m.no_remesa = d.no_remesa
			   and d.tipo_mov in ('P', 'N', 'X')
			   and d.doc_remesa = _no_documento
			   and m.fecha between _vigencia_inic and _vigencia_fin;
			   
				if _cnt_polpag > 0 then
					let _pagada = 1 ;
				end if				   
		end if	
		
	end if		

	if _pagada = 1 then
		select count(*)
		  into _cnt_poliza
		  from caspoliza
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_cliente;

		if _cnt_poliza is null then
			let _cnt_poliza = 0;
		end if

		if _cnt_poliza = 0 then
			delete from cascliente
			 where cod_campana = _cod_campana
			   and cod_cliente = _cod_cliente;
		end if

		delete from caspoliza
		 where cod_campana = _cod_campana
		   and no_documento = _no_documento;

		foreach
			select no_documento
			  into _no_documento
			  from cobanula
			 where no_documento = _no_documento

			insert into cobgesti(
					cod_gestion,
					fecha_gestion,
					cod_pagador,
					desc_gestion,
					no_documento,
					no_poliza,
					tipo_aviso,
					user_added)
			values(	_sus_gest_automatic,
					current,
					_cod_cliente,
					_nom_gestion,
					_no_documento,
					_no_poliza,
					_tipo_aviso,
					_user_added);

			delete from cobanula
			 where no_documento = _no_documento;
		end foreach

		let _cnt_delete = _cnt_delete + 1;
		--return 5, 'Pago' with resume;
	end if 
end foreach

return 0,'Proceso Exitoso. Se Eliminaron ' || trim(cast(_cnt_delete as char(4))) || ' Pólizas de las Campañas de Nulidad.';

end
end procedure;