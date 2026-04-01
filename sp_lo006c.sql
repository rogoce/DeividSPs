-- Pool de logistica para cancelacion - estados impresion 1 - 2 - 3 
-- Creado : 16/2/2016 - Autor: Henry  Giron.  
-- execute procedure sp_log006("I")  
-- drop procedure pr1009  

drop procedure sp_log006c;  
create procedure "informix".sp_log006c(a_estatus char(1) default "I")
              returning char(15),
						char(55),
						char(15),
						date,
						float,
						int,
						char(15),
						date,
						char(1), --estatus
						int,     --cnt_acreedor
						char(10),--rpt certifica
						int;     --rpt seleccion

define _no_aviso        char(15);
define _nombre_ramo     char(55);
define _user_proceso    char(15);
define _fecha_proceso   date;
define _sum_saldo       float;
define _count_no_poliza int;
define _user_imp_aviso_log char(15);
define _date_imp_aviso_log date;
define _estatus	 char(1);
--define _cod_avican     char(15);
define _total int;
define _no_documento   char(20);
define _cnt_estatus int;
define _cnt_color int;
define _cnt_acreedor int;
define _pool_log int;
define _rpt_crt  char(10);
define _rpt_sel  int;
define _rpt_cc   char(10);
define _rpt_sel_cc  int;

define _ano_char		    char(4);
define _mes_char		    char(2);
define _fecha_actual	    date;
define _dias_180			dec(16,2);
define _dias_150			dec(16,2);
define _dias_120			dec(16,2);
define _dias_90			    dec(16,2);
define _dias_60			    dec(16,2);
define _dias_30			    dec(16,2);
define _por_vencer_c	    dec(16,2);
define _corriente_c		    dec(16,2);
define _exigible_c			dec(16,2);
define _dias_30_c			dec(16,2);
define _dias_60_c			dec(16,2);
define _dias_90_c			dec(16,2);
define _dias_120_c			dec(16,2);
define _dias_150_c			dec(16,2);
define _dias_180_c			dec(16,2);
define _saldo_c 			dec(16,2);
define _saldo_sin_mora		dec(16,2);
define _saldo_pago			dec(16,2);
define _hay_pago			smallint;
define _periodo_c			char(7);
define _fecha_imprimir		date;
 define _saldo            float;
 define _no_poliza        char(10);
  define _cod_ramo       char(3);
define _contar			smallint;
define _siguiente			smallint;
let _rpt_crt  = "00000";

set isolation to dirty read;

let _count_no_poliza = 0;
let _user_imp_aviso_log = null;
let _date_imp_aviso_log = null;
let _fecha_proceso = null;
let _user_proceso = null;
let _sum_saldo = 0;
let _pool_log = 0;
let _rpt_crt = '';
let _rpt_sel = 0;
 let _saldo_sin_mora	= 0;
 let _hay_pago			= 0;

-- ,'X','Y')  -- Henry, solicitud usuario NSOLIS 2/8/2016
let _fecha_actual		= today;
if month(_fecha_actual) < 10 then
	let _mes_char = '0'|| month(_fecha_actual);
else
	let _mes_char = month(_fecha_actual);
end if

let _ano_char = year(_fecha_actual);
let _periodo_c  = _ano_char || "-" || _mes_char;

foreach
    select d.no_aviso, a.nombre, count(d.no_poliza)
      into _no_aviso,_nombre_ramo, _total
	  from avicanpar a, avisocanc d
     where a.cod_avican = d.no_aviso
	   and (d.no_aviso >= '00951') -- OR d.no_aviso = '00927')
     group by d.no_aviso, a.nombre
	--having count(d.no_poliza) >=  550
	 order by 1,2

	 {select count(*)
	   into _pool_log
	   from avisocanc
	  where no_aviso = (_no_aviso)
	  and year(fecha_imprimir) >= 2016
	  and month(fecha_imprimir) >= 4;

     if _pool_log is null then
	    let _pool_log  = 0;
    end if

     if _pool_log = 0 then
	    continue foreach;
    end if}

	 {select count(*)
	   into _cnt_estatus
	   from avisocanc
	  where estatus not in ('Y','I','W')
		and no_aviso = (_no_aviso);

     if _cnt_estatus is null then
	    let _cnt_estatus = 0;
    end if

     if _cnt_estatus <> 0 then
	    continue foreach;
    end if}

	foreach
		select user_proceso,
			   fecha_proceso,
			   count(distinct no_poliza)
		  into _user_proceso,
			   _fecha_proceso,
			   _count_no_poliza
		  from avisocanc
		 where estatus in ('I') --,'X','Y')  -- se aÃ±adio X y Y ,Henry, solicitud usuario NSOLIS 2/8/2016
		   and no_aviso = (_no_aviso)
           and saldo > 0 and exigible > 0    -- se corrige que tome encuenta que tenga exigible  GISELA/NSOLIS 17/8/2016
		  -- and ((dias_90 = 0 or (dias_150+dias_180) <= 5)))
		  and (saldo - (saldo - (dias_60+dias_90+dias_120+dias_150+dias_180))) > 5
      group by user_proceso,
			   fecha_proceso
		  exit foreach;
	 end foreach

	 -- //******
	 let _contar = 0;
	 foreach
 select  d.no_documento,
		 d.saldo,
		 d.no_poliza,
		 d.cod_ramo,
		 d.fecha_imprimir,
		 d.fecha_proceso,
		 d.dias_30,
		 d.dias_60,
		 d.dias_90,
		 d.dias_120,
		 d.dias_150,
		 d.dias_180,
		 d.estatus
	into _no_documento,
		_saldo,
		 _no_poliza,
		 _cod_ramo,
		_fecha_imprimir,
		 _fecha_proceso,
	     _dias_30,
	     _dias_60,
	     _dias_90,
	     _dias_120,
	     _dias_150,
	     _dias_180,
         _estatus
	  from avicanpar a, avisocanc d
     where d.estatus in ('I')  --,'X','Y')  -- Henry, solicitud  usuario NSOLIS 2/8/2016
     --  and (d.imprimir_log = 0 or d.imprimir_log is null)
       and a.cod_avican = d.no_aviso
       and d.saldo > 0 and d.exigible > 0	 -- Henry: 16/08/2016, se esta colocando para igualar ambos pool. solicitud de Gisela y Nimia
       and a.cod_avican = (_no_aviso)

	  	call sp_cob245a("001","001",_no_documento,_periodo_c,_fecha_actual)
		returning	_por_vencer_c,
					_exigible_c,
					_corriente_c,
					_dias_30_c,
					_dias_60_c,
					_dias_90_c,
					_dias_120_c,
					_dias_150_c,
					_dias_180_c,
					_saldo_c;

		if _saldo_c = 0  then
			continue foreach;
		end if

		let _dias_90  	= _dias_90+_dias_120+_dias_150+_dias_180;
		let _dias_120 	= 0.00;
		let _dias_150 	= 0.00;
		let _dias_180 	= 0.00;
		let _saldo_pago = 0.00;

		if _cod_ramo in ("004","016","018","019") then
			let _saldo_sin_mora = _saldo - (_dias_60+_dias_90);
		else
			let _saldo_sin_mora = _saldo - (_dias_60+_dias_90);
		end if

		if _estatus not in ('G') then
			if _fecha_imprimir is null then
			   let _fecha_imprimir = _fecha_proceso;
			end if

			let _hay_pago = 0;

			select count(*) -- saldo
			  into _hay_pago
			  from emipomae
			 where no_poliza = _no_poliza
			   and no_documento	= _no_documento
			   and fecha_ult_pago >= _fecha_imprimir;

			if _hay_pago >= 1 or _exigible_c <= 0 then
				let _saldo_pago = 0.00;

				select saldo
				  into _saldo_pago
				  from emipomae
				 where no_poliza = _no_poliza
				   and no_documento	= _no_documento
				   and fecha_ult_pago >= _fecha_imprimir;

				if _saldo_pago is null then
				   let _saldo_pago = 0.00;
				end if

				if (_saldo <= _saldo_sin_mora and abs(_saldo - _saldo_sin_mora) <= 5.00) then
					continue foreach;
				else
					 -- si el pago es en el dia
					 --trace off;
					call sp_cob245a("001","001",_no_documento,_periodo_c,_fecha_actual)
					returning	_por_vencer_c,
								_exigible_c,
								_corriente_c,
								_dias_30_c,
								_dias_60_c,
								_dias_90_c,
								_dias_120_c,
								_dias_150_c,
								_dias_180_c,
								_saldo_c;
					  --trace on;
					if _saldo_c = 0 then
						continue foreach;
					end if
				end if
			end if
		end if
		let _contar = _contar + 1;
		end foreach;
		let _count_no_poliza = _contar;
	 -- //******

	      if _count_no_poliza is null then
	         let _count_no_poliza = 0;
         end if

		 if _count_no_poliza = 0 then
			continue foreach;
		end if

	 	 --if _total = _count_no_poliza then

		select count(*)
		  into _cnt_color
		  from avisocanc
		 where decode(imp_aviso_log,null,0,imp_aviso_log) in (1,2)
		   and estatus in ('I')
		   and saldo > 0
		   and no_aviso = (_no_aviso);

		if _cnt_color is null then
		   let _cnt_color = 0;
	   end if

		if _cnt_color <> 0 then
			let _estatus = "1";
		else
			select count(*)
			  into _cnt_color
			  from avisocanc
			 where decode(imp_aviso_log,null,0,imp_aviso_log) in (0)
			   and estatus in ('I')
			   and saldo > 0
			   and no_aviso = (_no_aviso);

			if _cnt_color is null then
				let _cnt_color = 0;
			end if

			if _cnt_color = _count_no_poliza then
				let _estatus = "0";
			else
				select count(*)
				  into _cnt_color
				  from avisocanc
				 where decode(imp_aviso_log,null,0,imp_aviso_log) in (3)
				   and estatus in ('I')
				   and saldo > 0
				   and no_aviso = (_no_aviso);

				if _cnt_color is null then
					let _cnt_color = 0;
				end if

				if _cnt_color = _count_no_poliza then
						let _estatus = "3";
					else
						let _estatus = "1";
				end if
			end if

		end if

	    select sum(saldo)
		  into _sum_saldo
		  from avisocanc
		 where estatus in ('I')
		   and no_aviso = (_no_aviso);

		if _sum_saldo is null then
		   let _sum_saldo = 0;
	   end if

	  let _cnt_acreedor = 0;
	select count(*)
	  into _cnt_acreedor
	  from avisocanc
	 where estatus in ('I') and cancela = "0"
       and trim(cod_acreedor) <> ""
	   and no_aviso = (_no_aviso);

		if _cnt_acreedor is null then
		   let _cnt_acreedor = 0;
	   end if

	 select count(*)
	   into _cnt_estatus
	   from avisocanc
	  where estatus in ('I')
	    and saldo > 0
		and no_aviso = (_no_aviso);

     if _cnt_estatus is null or _cnt_estatus = 0 then
	    --let _estatus = "2";
		continue foreach;
    end if

	select count(*)
	  into _cnt_estatus
	  from avisocanc
	 where no_aviso = (_no_aviso)
	   and estatus = 'I'
	   and saldo > 0 and exigible > 0
	   and imp_aviso_log <> 3;

     if _cnt_estatus is null or _cnt_estatus = 0 then
	    let _estatus = "3";
    end if

	let  _rpt_crt  = "00000";
	let _rpt_sel = 0;

   let _siguiente = 0 ;
	foreach
		select distinct(reporte_certifica),count(*)
		  into _siguiente,_rpt_sel
		  from avisocanc
		 where no_aviso = (_no_aviso)
		   --and estatus in ('I')
		   and imp_aviso_log = 3
--           and marcar_entrega = 2
           and marcar_certifica = 1
		   group by 1
		   order by 1 desc

			IF _siguiente > 9999 THEN
				LET _rpt_crt = _siguiente;
			ELIF _siguiente > 999 THEN
				LET _rpt_crt[2,5] = _siguiente;
			ELIF _siguiente > 99  THEN
				LET _rpt_crt[3,5] = _siguiente;
			ELIF _siguiente > 9  THEN
				LET _rpt_crt[4,5] = _siguiente;
			ELSE
				LET _rpt_crt[5,5] = _siguiente;
			END IF


		  exit foreach;
	 end foreach

	 let  _rpt_cc  = "00000";
	 let _rpt_sel_cc = 0;


	 foreach
		select count(*)
		  into _rpt_sel_cc
		  from avisocanc
		 where no_aviso = (_no_aviso)
		   --and estatus in ('I')      -- Zuleyka:29/09/2016, Seleccionar Estaus Y,I que hallan sido impreso x logistica
		   and imp_aviso_log = 3  and clase = 2
           --and marcar_entrega = 2

			{IF _siguiente > 9999 THEN
				LET _rpt_cc = _rpt_sel_cc;
			ELIF _siguiente > 999 THEN
				LET _rpt_cc[2,5] = _rpt_sel_cc;
			ELIF _siguiente > 99  THEN
				LET _rpt_cc[3,5] = _rpt_sel_cc;
			ELIF _siguiente > 9  THEN
				LET _rpt_cc[4,5] = _rpt_sel_cc;
			ELSE
				LET _rpt_cc[5,5] = _rpt_sel_cc;
			END IF	}

		  exit foreach;
	 end foreach

     if _rpt_sel_cc <> 0 then
		let _count_no_poliza = _rpt_sel_cc;
	 end if

	 if _rpt_sel = 0 then
		let _rpt_sel = null;
	 end if
	 if _siguiente = 0 then
		let _rpt_crt = null;
	 end if


	return _no_aviso,
		   _nombre_ramo,
		   _user_proceso,
		   _fecha_proceso,
		   _sum_saldo,
		   _count_no_poliza,
		   _user_imp_aviso_log,
		   _date_imp_aviso_log,
		   _estatus,
           _cnt_acreedor,
           _rpt_crt,
		   _rpt_sel
		with resume;

	--end if



end foreach


end procedure


