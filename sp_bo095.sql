--Generación y Carga de morosidad en formato NIIF (tmp_morosidad)
--execute procedure sp_bo095('2018-03','2018-03',0)

drop procedure sp_bo095; 

create procedure sp_bo095(a_periodo_desde char(7), a_periodo_hasta char(7), a_flag smallint default 0)
returning integer,
          char(50);

define _descripcion			varchar(50);
define _error_desc			varchar(50);
define _no_documento		char(20);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_grupo			char(5);
define _cod_ramo			char(3);
define _por_vencer_pxc		dec(16,2);
define _corriente_pxc		dec(16,2);
define _monto_180_pxc		dec(16,2);
define _monto_150_pxc		dec(16,2);
define _monto_120_pxc		dec(16,2);
define _monto_90_pxc		dec(16,2);
define _monto_60_pxc		dec(16,2);
define _monto_30_pxc		dec(16,2);
define _monto_rehab			dec(16,2);
define _monto_canc			dec(16,2);
define _saldo_pxc			dec(16,2);
define _facultativo			smallint;
define _cnt_existe			smallint;
define _flag_grupo			smallint;
define _cnt_rehab			smallint;
define _cnt_canc			smallint;
define _fronting			smallint;
define _error				integer;
define _error_isam			integer;
define _fecha_periodo		date;
define _fecha_rehab			date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception
let _periodo = a_periodo_desde;

let _por_vencer_pxc = 0.00;
let _corriente_pxc = 0.00;
let _monto_30_pxc = 0.00;
let _monto_60_pxc = 0.00;
let _monto_90_pxc = 0.00;
let _monto_120_pxc = 0.00;
let _monto_150_pxc = 0.00;
let _monto_180_pxc = 0.00;
let _saldo_pxc = 0.00;

foreach with hold

	select no_documento
	  into _no_documento
	  from emipoliza

	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

	let _fecha_periodo = sp_sis36(_periodo);	--Retorna ultimo fecha con ultimo dia.
	let _no_poliza = null;

	foreach
		select no_poliza
		  into _no_poliza
		  from emipomae
		 where no_documento = _no_documento
		   and vigencia_inic < _fecha_periodo
		 order by vigencia_inic desc
		exit foreach;
	end foreach

	if _no_poliza is null then
		foreach
			select no_poliza
			  into _no_poliza
			  from emipomae
			 where no_documento = _no_documento
			 order by vigencia_inic asc
			exit foreach;
		end foreach
	end if

	select count(*)
	  into _cnt_canc
	  from endedmae
	 where no_poliza = _no_poliza
	   and cod_endomov = '002'
	   and cod_tipocan = '001'
	   and actualizado = 1;

	if _cnt_canc is null then
		let _cnt_canc = 0;
	end if
	
	if _saldo_pxc = 0.00 and _cnt_canc = 0 then
		commit work;
		continue foreach;
	end if

	select cod_ramo,
		   cod_grupo
	  into _cod_ramo,
		   _cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza;

	let _flag_grupo = 0;
	let _fronting = sp_sis135(_no_poliza);
	let _facultativo = sp_sis439(_no_poliza);

	if _cod_grupo in ('1000','00000') then --Grupos del Estado
		let _flag_grupo = 1;
	end if

	--Verifica si la póliza fue cancelada por falta de pago
	if _cnt_canc = 0 then
		let _monto_rehab = 0.00;
		let _monto_canc = 0.00;
	else
		let _fecha_rehab = null;

		select min(fecha_emision)
		  into _fecha_rehab
		  from endedmae
		 where no_poliza = _no_poliza
		   and cod_endomov = '003'
		   and actualizado = 1;

		if _fecha_rehab is null then
			let _monto_rehab = 0.00;
		else
			select sum(prima_neta)
			  into _monto_rehab
			  from cobredet
			 where no_poliza = _no_poliza
			   and fecha >= _fecha_rehab
			   and periodo = _periodo
			   and actualizado = 1;

			if _monto_rehab is null then
				let _monto_rehab = 0.00;
			end if
		end if
	end if

	begin
		on exception in(-239,-268)
			update deivid_cob:tmp_morosidad
			   set por_vencer_pxc = por_vencer_pxc + _por_vencer_pxc,
				   corriente_pxc = corriente_pxc + _corriente_pxc,
				   monto_30_pxc = monto_30_pxc + _monto_30_pxc,
				   monto_60_pxc = monto_60_pxc + _monto_60_pxc,
				   monto_90_pxc = monto_90_pxc + _monto_90_pxc,
				   monto_120_pxc = monto_120_pxc + _monto_120_pxc,
				   monto_150_pxc = monto_150_pxc + _monto_150_pxc,
				   monto_180_pxc = monto_180_pxc + _monto_180_pxc,
				   saldo_pxc = _saldo_pxc + _saldo_pxc
			 where periodo = _periodo
			   and cod_ramo = _cod_ramo
			   and no_poliza = _no_poliza;
		end exception 	

		insert into deivid_cob:tmp_morosidad(
				periodo,
				cod_ramo,
				no_poliza,
				por_vencer_pxc,
				corriente_pxc,
				monto_30_pxc,
				monto_60_pxc,
				monto_90_pxc,
				monto_120_pxc,
				monto_150_pxc,
				monto_180_pxc,
				saldo_pxc,
				monto_cancelacion,
				monto_rehab,
				facultativo,
				fronting,
				gobierno)
		values(	_periodo,
				_cod_ramo,
				_no_poliza,
				_por_vencer_pxc,
				_corriente_pxc,
				_monto_30_pxc,
				_monto_60_pxc,
				_monto_90_pxc,
				_monto_120_pxc,
				_monto_150_pxc,
				_monto_180_pxc,
				_saldo_pxc,
				0.00,
				_monto_rehab,
				_facultativo,
				_fronting,
				_flag_grupo);
	end

	commit work;
end foreach

foreach with hold
	select no_poliza,
		   periodo,
		   sum(prima_neta)
	  into _no_poliza,
		   _periodo,
		   _monto_canc
	  from endedmae
	 where cod_endomov = '002'
	   and cod_tipocan = '001'
	   and periodo between a_periodo_desde and a_periodo_hasta
	   and actualizado = 1
	 group by 1,2
	 order by 2,1

	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

	select cod_ramo,
		   cod_grupo
	  into _cod_ramo,
		   _cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza;

	let _flag_grupo = 0;
	let _fronting = sp_sis135(_no_poliza);
	let _facultativo = sp_sis439(_no_poliza);

	if _cod_grupo in ('1000','00000') then --Grupos del Estado
		let _flag_grupo = 1;
	end if

	begin
		on exception in(-239,-268)
			update deivid_cob:tmp_morosidad
			   set monto_cancelacion = monto_cancelacion + _monto_canc
			 where periodo = _periodo
			   and cod_ramo = _cod_ramo
			   and no_poliza = _no_poliza;
		end exception 	

		insert into deivid_cob:tmp_morosidad(
				periodo,
				cod_ramo,
				no_poliza,
				por_vencer_pxc,
				corriente_pxc,
				monto_30_pxc,
				monto_60_pxc,
				monto_90_pxc,
				monto_120_pxc,
				monto_150_pxc,
				monto_180_pxc,
				saldo_pxc,
				monto_cancelacion,
				monto_rehab,
				facultativo,
				fronting,
				gobierno)
		values(	_periodo,
				_cod_ramo,
				_no_poliza,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				_monto_canc,
				0.00,
				_facultativo,
				_fronting,
				_flag_grupo);
	end

	commit work;
end foreach
return 0,'Actualización Exitosa';
end
end procedure;