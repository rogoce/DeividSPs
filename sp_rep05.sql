--- Procedimiento que genera el cuadro de mando cobros
-- Creado    : 09/04/2015 -- Federico Coronado

drop procedure sp_rep05;
create procedure sp_rep05(a_periodo_ini char(7), a_periodo_fin char(7),a_opcion smallint)
returning	varchar(20),
			char(3),
			varchar(50),
			dec(10,2),
			dec(10,2),
			dec(10,2),
			dec(10,2),
			dec(10,2),
			dec(10,2),
			dec(10,2),
			dec(10,2),
			dec(10,2),
			dec(10,2),
			dec(10,2),
			smallint;

-- Actualizar Polizas Nuevas

define _doc_poliza		varchar(50);
define _nombre			varchar(50);
define _nom_div_cob		varchar(20);
define _no_poliza		varchar(10);
define v_cod_cobrador	char(3);
define _cod_formapag		char(3);
define _cod_tipoprod		char(3);
define _cod_coasegur		char(3);
define _cod_div_cob		char(1);  
define _grupo				smallint;
define _cnt				smallint;
define _monto				dec(10,2);
define _meta				dec(10,2);
define _por_vencer_neto	dec(16,2);
define _por_vencer_pxc	dec(16,2);
define _porc_coaseguro	dec(16,2);
define _corriente_neto	dec(16,2);
define _porc_part_agt	dec(16,2);
define _corriente_pxc	dec(16,2);
define _exigible_neto	dec(16,2);
define _monto_90_neto	dec(16,2);
define _monto_60_neto	dec(16,2);
define _monto_30_neto	dec(16,2);
define _porc_impuesto	dec(16,2);
define _exigible_pxc		dec(16,2);	
define _monto_90_pxc		dec(16,2); 
define _monto_60_pxc		dec(16,2); 
define _monto_30_pxc		dec(16,2); 
define _montoPagado		dec(16,2);
define _saldo_total		dec(16,2);
define _montoTotal		dec(16,2);
define _x_recaudar		dec(10,2);
define _por_vencer		dec(16,2);
define _corriente			dec(16,2);
define _monto_180			dec(16,2);
define _monto_150			dec(16,2);
define _monto_120			dec(16,2);
define _monto_90			dec(16,2);
define _monto_60			dec(16,2);
define _monto_30			dec(16,2);
define _exigible			dec(16,2);
define _porc_90			dec(10,2);
define _fecha				date;


--set debug file to "sp_repo05.trc";
--trace on;
--trace "1";

set isolation to dirty read;

let _x_recaudar = 0.00;
let _monto = 0.00;
let _meta = 0.00;
let _grupo = 1;
let _fecha = sp_sis36(a_periodo_fin);

select par_ase_lider
  into _cod_coasegur
  from parparam;
  
CREATE TEMP TABLE tmp_cobros(
no_documento	CHAR(18),
monto			dec(10,2),
cod_formapag	char(3),
nombre			varchar(50),
por_vencer		dec(10,2),
exigible		dec(10,2),
corriente		dec(10,2),
_30dias		dec(10,2),
_60dias		dec(10,2),
_90dias		dec(10,2),
cod_div_cob	char(1),
nombre_div		varchar(20)
--no_poliza           varchar(10)
) WITH NO LOG;
CREATE INDEX idx_01_tmp_cobros ON tmp_cobros(no_documento);

foreach
	select doc_remesa,
		   sum(monto)
	  into _doc_poliza,
		   _monto
	  from cobredet 
	 where actualizado 	= 1
	   and tipo_mov IN ('P','N')
	   and periodo 		>= a_periodo_ini
	   and periodo 		<= a_periodo_fin
	 group by doc_remesa
 
	if _monto is null then
		let _monto = 0.00;
	end if

	let _no_poliza = sp_sis21(_doc_poliza);

	if _no_poliza is null then
		continue foreach;
	end if

	select cod_tipoprod,
		   cobra_poliza,
		   cod_formapag
	  into _cod_tipoprod,
	       _cod_div_cob,
		   _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza
	   and actualizado = 1;

	select nombre
      into _nombre
	  from cobforpa
	 where cod_formapag = _cod_formapag;
	 
	-- Zona de Cobros		
	select nombre
	  into _nom_div_cob
	  from cobdivis
	 where cod_division = _cod_div_cob;

	if _cod_tipoprod = "004" then

		let _por_vencer_neto = 0.00;
		let _corriente_neto = 0.00;
		let _exigible_neto = 0.00;
		let _monto_30_neto = 0.00;
		let _monto_60_neto = 0.00;
		let _monto_90_neto = 0.00;
		let _saldo_total = 0.00;
		let _por_vencer = 0.00;   
		let _corriente = 0.00; 
		let _monto_120 = 0.00;
		let _monto_150 = 0.00;
		let _monto_180 = 0.00;
		let _exigible = 0.00;
		let _monto_30 = 0.00;  
		let _monto_60 = 0.00; 
		let _monto_90 = 0.00;
		let _monto = 0.00;

	else
			CALL sp_cob245(
			"001",
			"001",
			_doc_poliza,
			a_periodo_fin,
			_fecha)
			RETURNING	_por_vencer,      
						_exigible,         
						_corriente,        
						_monto_30,         
						_monto_60,         
						_monto_90,
						_monto_120,
						_monto_150,
						_monto_180,
						_saldo_total;

			select sum(i.factor_impuesto)
			  into _porc_impuesto
			  from emipolim p, prdimpue i
			 where p.cod_impuesto = i.cod_impuesto
			   and p.no_poliza    = _no_poliza;  

			if _porc_impuesto is null then
				let _porc_impuesto = 0.00;
			end if

			let _por_vencer_pxc	= _por_vencer	/ (1 + (_porc_impuesto / 100));
			let _corriente_pxc  = _corriente    / (1 + (_porc_impuesto / 100));
			let _exigible_pxc 	= _exigible   	/ (1 + (_porc_impuesto / 100));
			let _monto_30_pxc   = _monto_30     / (1 + (_porc_impuesto / 100));
			let _monto_60_pxc   = _monto_60     / (1 + (_porc_impuesto / 100));
			let _monto_90_pxc   = _monto_90     / (1 + (_porc_impuesto / 100));
			-- Primas por Cobrar - Coaseguro Mayoritario

			let _por_vencer_neto = _por_vencer_pxc;
			let _corriente_neto = _corriente_pxc;
			let _exigible_neto = _exigible_pxc;
			let _monto_30_neto = _monto_30_pxc;
			let _monto_60_neto = _monto_60_pxc;
			let _monto_90_neto = _monto_90_pxc;

			if _cod_tipoprod = "001" then

				select porc_partic_coas
				  into _porc_coaseguro
				  from emicoama
				 where no_poliza    = _no_poliza
				   and cod_coasegur = _cod_coasegur;

				if _porc_coaseguro is null then
					let _porc_coaseguro = 0.00;
				end if

				let _por_vencer_neto = _por_vencer_neto * (_porc_coaseguro / 100);
				let _corriente_neto = _corriente_neto  * (_porc_coaseguro / 100);
				let _exigible_neto = _exigible_neto   * (_porc_coaseguro / 100);
				let _monto_30_neto = _monto_30_neto   * (_porc_coaseguro / 100);
				let _monto_60_neto = _monto_60_neto   * (_porc_coaseguro / 100);
				let _monto_90_neto = _monto_90_neto   * (_porc_coaseguro / 100);

			end if
		 
			insert into tmp_cobros(
						no_documento,   
						monto,          
						cod_formapag,   
						nombre,         
						por_vencer,     
						exigible,       
						corriente,      
						_30dias,        
						_60dias,        
						_90dias,
						cod_div_cob, 
						nombre_div)
			values(	_doc_poliza,
						_monto,
						_cod_formapag,
						_nombre,
						_por_vencer,
						_exigible,  
						_corriente, 
						_monto_30,  
						_monto_60,  
						_monto_90,
						_cod_div_cob, 
						_nom_div_cob);
	end if
end foreach

--Agregar  Meta Gob,debido a que no hay cobros
select count(*)
  into _cnt
  from tmp_cobros
 where cod_formapag = '091';
 
if _cnt is null then
	let _cnt = 0;
end if

if _cnt = 0 then
	insert into tmp_cobros(
			no_documento,   
			monto,          
			cod_formapag,   
			nombre,         
			por_vencer,     
			exigible,       
			corriente,      
			_30dias,        
			_60dias,        
			_90dias,
			cod_div_cob, 
			nombre_div
			)
	values( '',
				0,
				'091',
				'GOB - GOBIERNO',
				0,
				0,  
				0, 
				0,  
				0,  
				0,
				'',
				''
				);
end if
--Agregar  Meta COA COASEGURO MINORITARIO,debido a que no hay cobros
select count(*)
  into _cnt
  from tmp_cobros
 where cod_formapag = '084';
 
if _cnt is null then
	let _cnt = 0;
end if

if _cnt = 0 then
	insert into tmp_cobros(
			no_documento,   
			monto,          
			cod_formapag,   
			nombre,         
			por_vencer,     
			exigible,       
			corriente,      
			_30dias,        
			_60dias,        
			_90dias,
			cod_div_cob, 
			nombre_div
			)
	values( '',
				0,
				'084',
				'COA - COASEGURO MINORITARIO',
				0,
				0,  
				0, 
				0,  
				0,  
				0,
				'',
				''
				);
end if
--****	
foreach
	select  no_documento,
			sum(por_vencer),
			sum(exigible), 
			sum(corriente),
			sum(_30dias),
			sum(_60dias),
			sum(_90dias),
			sum(monto)
	  into  _doc_poliza,
			_por_vencer,
			_exigible,
			_corriente,
			_monto_30,
			_monto_60,  
			_monto_90,
			_monto
	  from tmp_cobros
	 group by no_documento 

	let _no_poliza = sp_sis21(_doc_poliza);

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza
	 and actualizado = 1;

	if _cod_tipoprod = "004" then
		continue foreach;
	end if
	
	let _montototal = _corriente + _monto_30 + _monto_60 + _monto_90 + _por_vencer;
	let _montopagado = _monto;

	if _montototal > 0 then
		if _monto_90 <> 0 then
			if _monto_90 >= _montopagado then

				let _monto_90 = _montopagado;
				let _montopagado = 0;
				let _por_vencer = 0;
				let _corriente = 0;
				let _monto_60 = 0;
				let _monto_30 = 0;
			else
				let _montopagado = _montopagado - _monto_90;
			end if	
		end if

		if _monto_60 <> 0 then
			if _monto_60 >= _montopagado then
				let _monto_60 = _montopagado;
				let _monto_30 = 0;
				let _corriente = 0;
				let _por_vencer = 0;
				let _montopagado = 0;
			else
				let _montopagado = _montopagado - _monto_60;
			end if	
		end if

		if _monto_30 <> 0 then
			if _monto_30 >= _montopagado then
				let _monto_30    = _montopagado;
				let _corriente   = 0;
				let _por_vencer  = 0;
				let _montopagado = 0;
			else
				let _montopagado = _montopagado - _monto_30;
			end if	
		end if
		
		if _corriente <> 0 then
			if _corriente >= _montopagado then
				let _corriente   = _montopagado;
				let _por_vencer  = 0;
				let _montopagado = 0;
			else
				let _montopagado = _montopagado - _corriente;
			end if	
		end if

		if _por_vencer <> 0 then
			let _por_vencer  = _montopagado;
			let _montopagado = 0;
		end if

		if _montopagado <> 0 then
			let _corriente = _corriente + _montopagado;
		end if
	else

		let _monto_90   = 0;
		let _monto_60   = 0;
		let _monto_30   = 0;
		let _corriente  = _montopagado;
		let _por_vencer = 0;
	end if

	let _exigible = _corriente + _monto_30 + _monto_60 + _monto_90;

	update tmp_cobros
	   set	por_vencer = _por_vencer,
			exigible   = _exigible,
			corriente  = _corriente,
			_30dias    = _monto_30,
			_60dias    = _monto_60,
			_90dias    = _monto_90
	 where no_documento  = _doc_poliza;

end foreach	

if a_opcion = 0 then
	foreach
		select nombre,
			    cod_formapag,
				sum(monto),
				sum(por_vencer),
				sum(exigible),
				sum(corriente),
				sum(_30dias),
				sum(_60dias),
				sum(_90dias)
		  into _nombre,
			   _cod_formapag,
			   _monto,
			   _por_vencer,
			   _exigible,
			   _corriente,
			   _monto_30,
			   _monto_60,
			   _monto_90
		 from tmp_cobros
		group by cod_formapag,nombre
		order by nombre

		select sum(monto)
		  into _meta
		  from cobprefo
		 where cod_formapag = _cod_formapag
		   and periodo 		>= a_periodo_ini
		   and periodo 		<= a_periodo_fin; 
		   
		if _meta is null then
			let _meta = 0.00;
		end if  

		let _x_recaudar 	= _meta - _monto;

		if _meta > 0 then
			let _porc_part_agt = (_monto / _meta)*100;
			let _porc_90 = (_monto_90 / _meta)*100;
		else
			let _porc_part_agt = 0;
			let _porc_90 = 0;
		end if
	
		if _cod_formapag = '085' then
			let _grupo = 2;
		else
			let _grupo = 1;
		end if
			
		return	"Forma de Pago",
				_cod_formapag,
				_nombre, 
				_monto,
				_meta,
				_x_recaudar,
				_porc_part_agt,
				_por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,  
				_monto_90,
				_porc_90,
				_grupo
				with resume;  
	end foreach
else
	foreach
		select nombre_div,
			    cod_div_cob,
				sum(monto),
				sum(por_vencer),
				sum(exigible),
				sum(corriente),
				sum(_30dias),
				sum(_60dias),
				sum(_90dias)
		  into _nombre,
			    _cod_div_cob,
				_monto,
				_por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90
		  from tmp_cobros
		 group by nombre_div, cod_div_cob
		 order by nombre_div
		   
		if _meta is null then
			let _meta = 0.00;
		end if  

		let _x_recaudar 	= _meta - _monto;

		if _meta > 0 then
			let _porc_part_agt = (_monto / _meta)*100;
			let _porc_90 = (_monto_90 / _meta)*100;
		else
			let _porc_part_agt = 0;
			let _porc_90 = 0;
		end if

	return	"Division",
			_cod_div_cob,
			_nombre, 
			_monto,
			_meta,
			_x_recaudar,
			_porc_part_agt,
			_por_vencer,
			_exigible,
			_corriente,
			_monto_30,
			_monto_60,  
			_monto_90,
			_porc_90,
			_grupo
			with resume;  
	end foreach
end if
DROP TABLE tmp_cobros;
end procedure;