-- Procedimiento que carga los datos para presupuesto del 2010 por ramo
 
-- 23/11/2009 - Autor: Armando Moreno M.

drop procedure sp_preram8;

create procedure "informix".sp_preram8()
returning integer,
		  char(100);

define _cod_ramo		char(3);
define _tipo_mov		char(2);

define _nueva_renov		char(1);
define _vigencia_inic	date;
define _vigencia_final	date;

define _no_poliza		char(10);
define _no_endoso		char(5);
define _periodo			char(7);
define _prima_suscrita	dec(16,2);
define _p_sus_cont      dec(16,2);
define _p_sus           dec(16,2);
define _prima_retenida  dec(16,2);
define _cod_endomov		char(3);
define _cod_contrato	char(5);
define _fronting		smallint;
define _tipo_contrato   smallint;
define _error_desc		char(100);
define _p_ced_tot		dec(16,2);
define _p_ced 			dec(16,2);
define _monto_comision	dec(16,2);
define _total_2009      dec(16,2);
define _total_2008      dec(16,2);
define _total_20083     dec(16,2);
define _total_20084     dec(16,2);
define _total_final     dec(16,2);
define _porc_ene		dec(16,5);
define _porc_feb		dec(16,5);
define _porc_mar		dec(16,5);
define _porc_abr		dec(16,5);
define _porc_may		dec(16,5);
define _porc_jun		dec(16,5);
define _porc_jul		dec(16,5);
define _porc_ago		dec(16,5);
define _porc_sep		dec(16,5);
define _porc_oct		dec(16,5);
define _porc_nov		dec(16,5);
define _porc_dic		dec(16,5);
define _porc_09         dec(16,5);
define _ene2			dec(16,2);
define _feb2			dec(16,2);
define _mar2			dec(16,2);
define _abr2			dec(16,2);
define _may2			dec(16,2);
define _jun2			dec(16,2);
define _jul2			dec(16,2);
define _ago2			dec(16,2);
define _sep2			dec(16,2);
define _oct2			dec(16,2);
define _nov2			dec(16,2);
define _dic2			dec(16,2);
define _ene			    dec(16,2);
define _feb				dec(16,2);
define _mar				dec(16,2);
define _abr				dec(16,2);
define _may				dec(16,2);
define _jun				dec(16,2);
define _jul				dec(16,2);
define _ago				dec(16,2);
define _sep				dec(16,2);
define _oct				dec(16,2);
define _nov				dec(16,2);
define _dic				dec(16,2);
define _ene3			dec(16,2);
define _feb3			dec(16,2);
define _mar3			dec(16,2);
define _abr3			dec(16,2);
define _may3			dec(16,2);
define _jun3			dec(16,2);
define _jul3			dec(16,2);
define _ago3			dec(16,2);
define _sep3			dec(16,2);
define _oct3			dec(16,2);
define _nov3			dec(16,2);
define _dic3			dec(16,2);
define _ene4			dec(16,2);
define _feb4			dec(16,2);
define _mar4			dec(16,2);
define _abr4			dec(16,2);
define _may4			dec(16,2);
define _jun4			dec(16,2);
define _jul4			dec(16,2);
define _ago4			dec(16,2);
define _sep4			dec(16,2);
define _oct4			dec(16,2);
define _nov4			dec(16,2);
define _dic4			dec(16,2);
define _ene_final   	dec(16,2);
define _feb_final   	dec(16,2);
define _mar_final		dec(16,2);
define _abr_final		dec(16,2);
define _may_final		dec(16,2);
define _jun_final		dec(16,2);
define _jul_final		dec(16,2);
define _ago_final		dec(16,2);
define _sep_final		dec(16,2);
define _oct_final		dec(16,2);
define _nov_final		dec(16,2);
define _dic_final		dec(16,2);
define _cod_cober_reas  char(3);
define _tiene_com		smallint;
define _porc_comision	decimal(5,2);
define _monto_contrato  dec(16,2);
define _porc_cont_partic decimal(9,6);
define _monto_comision_fin dec(16,2);
define _valor,_valor2   dec(16,2);

let _tipo_mov = "32";

foreach
  select no_poliza,
         no_endoso,
		 periodo,
         prima_suscrita,
		 cod_endomov,
		 vigencia_final,
		 prima_retenida
    into _no_poliza,
	     _no_endoso,
		 _periodo,
         _prima_suscrita,
         _cod_endomov,
         _vigencia_final,
         _prima_retenida
    from endedmae
   where actualizado  = 1
     and periodo      >= "2008-11"
	 and periodo      <= "2009-10"

	let _p_sus_cont = 0;
	let _p_ced      = 0;
	let _monto_comision = 0;
	let _monto_contrato = 0;
	let _valor  = 0;
	let _valor  = 0;
	let _valor2 = 0;
	let _monto_comision_fin = 0;

	foreach

		select cod_contrato,
		       prima,
			   cod_cober_reas
		  into _cod_contrato,
		       _p_sus,
			   _cod_cober_reas
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso

		select tipo_contrato
		  into _tipo_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _tipo_contrato = 1 or _tipo_contrato = 3 then --retencion,facultativo
			continue foreach;
		else

			let _monto_comision = 0;

			select tiene_comision,
			       porc_comision
			  into _tiene_com,
			       _porc_comision
			  from reacocob
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			let _monto_contrato = 0;

			if _tiene_com = 1 then   --por contrato

			   let _monto_contrato = _p_sus * _porc_comision / 100;

			   let _monto_comision = _monto_comision + _monto_contrato;

			elif _tiene_com = 2 then --por reasegurador

				let _valor  = 0;
				let _valor2 = 0;
				foreach

					select porc_cont_partic,
						   porc_comision
					  into _porc_cont_partic,
					       _porc_comision
					  from reacoase
					 where cod_contrato   = _cod_contrato
					   and cod_cober_reas = _cod_cober_reas

				   let _valor  = _p_sus * _porc_cont_partic / 100;
				   let _valor  = _valor * _porc_comision / 100;
				   let _valor2 = _valor2 + _valor;
					
				end foreach

			end if

		    let _monto_comision_fin = _monto_comision_fin + _monto_comision + _valor2;

		end if

	end foreach

	select nueva_renov,
	       cod_ramo,
		   vigencia_inic
	  into _nueva_renov,
	       _cod_ramo,
		   _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;

	-- Movimientos Mensuales

	if _periodo[6,7] = "01" then

		update preram2010
		   set ene          = ene + _monto_comision_fin
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "02" then

		update preram2010
		   set feb          = feb + _monto_comision_fin
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "03" then

		update preram2010
		   set mar          = mar + _monto_comision_fin
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "04" then

		update preram2010
		   set abr          = abr + _monto_comision_fin
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "05" then

		update preram2010
		   set may          = may + _monto_comision_fin
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "06" then

		update preram2010
		   set jun          = jun + _monto_comision_fin
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "07" then

		update preram2010
		   set jul          = jul + _monto_comision_fin
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "08" then

		update preram2010
		   set ago          = ago + _monto_comision_fin
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "09" then

		update preram2010
		   set sep          = sep + _monto_comision_fin
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "10" then

		update preram2010
		   set oct          = oct + _monto_comision_fin
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "11" then

		update preram2010
		   set nov          = nov + _monto_comision_fin
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "12" then

		update preram2010
		   set dic          = dic + _monto_comision_fin
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	end if

end foreach

-- Totales Horizontales

foreach
 select cod_ramo,
		tipo_mov,
		(ene + feb + mar + abr + may + jun + jul + ago + sep + oct + nov + dic)
   into _cod_ramo,
		_tipo_mov,
		_total_2009
   from preram2010
  where tipo_mov = _tipo_mov
   order by 1,2

 update preram2010
    set total_2009   = _total_2009
  where cod_ramo     = _cod_ramo
    and tipo_mov     = _tipo_mov;

end foreach

-- Calculo del % Ingreso sobre cesion

foreach
	 select cod_ramo,
			tipo_mov,
			ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
	   into _cod_ramo,
			_tipo_mov,
			_ene2,_feb2,_mar2,_abr2,_may2,_jun2,_jul2,_ago2,_sep2,_oct2,_nov2,_dic2,_total_2009
	   from preram2010
	  where tipo_mov = '32'
	  order by 1

	select ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
	  into _ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic,_total_2008
	  from preram2010
	 where cod_ramo   = _cod_ramo
	   and tipo_mov   = "5";

	select ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
	  into _ene3,_feb3,_mar3,_abr3,_may3,_jun3,_jul3,_ago3,_sep3,_oct3,_nov3,_dic3,_total_20083
	  from preram2010
	 where cod_ramo   = _cod_ramo
	   and tipo_mov   = "4";

	select ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
	  into _ene4,_feb4,_mar4,_abr4,_may4,_jun4,_jul4,_ago4,_sep4,_oct4,_nov4,_dic4,_total_20084
	  from preram2010
	 where cod_ramo   = _cod_ramo
	   and tipo_mov   = "3";

	let _porc_ene =	0;
	let _porc_feb =	0;
	let _porc_mar =	0;
	let _porc_abr =	0;
	let _porc_may =	0;
	let _porc_jun =	0;
	let _porc_jul =	0;
	let _porc_ago =	0;
	let _porc_sep =	0;
	let _porc_oct =	0;
	let _porc_nov =	0;
	let _porc_dic =	0;
	let _porc_09  = 0;
	let _total_final = 0;
	let _ene_final   = 0;
	let _feb_final   = 0;
	let	_mar_final	 = 0;
	let	_abr_final	 = 0;
	let	_may_final	 = 0;
	let	_jun_final	 = 0;
	let	_jul_final	 = 0;
	let	_ago_final	 = 0;
	let	_sep_final	 = 0;
	let	_oct_final	 = 0;
	let	_nov_final	 = 0;
	let	_dic_final	 = 0;

	let _total_final = _total_2008 - _total_20083 - _total_20084;

	if _total_final <> 0 then
		let _porc_09 =  (_total_2009 / _total_final) * 100;
	end if

	let _ene_final = _ene - _ene3 - _ene4;
	if _ene_final <> 0 then
		let _porc_ene =  (_ene2 / _ene_final) * 100;
	end if

	let _feb_final = _feb - _feb3 - _feb4;
	if _feb_final <> 0 then
		let _porc_feb =  (_feb2 / _feb_final) * 100;
	end if

	let	_mar_final	 = _mar - _mar3 - _mar4;
	if _mar_final <> 0 then
		let _porc_mar =  (_mar2 / _mar_final) * 100;
	end if

	let _abr_final = _abr - _abr3 - _abr4;
	if _abr_final <> 0 then
		let _porc_abr =  (_abr2 / _abr_final) * 100;
	end if

	let _may_final = _may - _may3 - _may4;
	if _may_final <> 0 then
		let _porc_may =  (_may2 / _may_final) * 100;
	end if

	let _jun_final = _jun - _jun3 - _jun4;
	if _jun_final <> 0 then
		let _porc_jun =  (_jun2 / _jun_final) * 100;
	end if

	let _jul_final = _jul - _jun3 - _jun4;
	if _jul_final <> 0 then
		let _porc_jul =  (_jul2 / _jul_final) * 100;
	end if

	let _ago_final = _ago - _ago3 - _ago4;
	if _ago_final <> 0 then
		let _porc_ago =  (_ago2 / _ago_final) * 100;
	end if

	let _sep_final = _sep - _sep3 - _sep4;
	if _sep_final <> 0 then
		let _porc_sep =  (_sep2 / _sep_final) * 100;
	end if

	let _oct_final = _oct - _oct3 - _oct4;
	if _oct_final <> 0 then
		let _porc_oct =  (_oct2 / _oct_final) * 100;
	end if

	let _nov_final = _nov - _nov3 - _nov4;
	if _nov_final <> 0 then
		let _porc_nov =  (_nov2 / _nov_final) * 100;
	end if

	let _dic_final = _dic - _dic3 - _dic4;
	if _dic_final <> 0 then
		let _porc_dic =  (_dic2 / _dic_final) * 100;
	end if

	update preram2010
	   set ene = _porc_ene,
		   feb = _porc_feb,
		   mar = _porc_mar,
		   abr = _porc_abr,
		   may = _porc_may,
		   jun = _porc_jun,
		   jul = _porc_jul,
		   ago = _porc_ago,
		   sep = _porc_sep,
		   oct = _porc_oct,
		   nov = _porc_nov,
		   dic = _porc_dic,
	 total_2009 = _porc_09
 	 where cod_ramo = _cod_ramo
  	   and tipo_mov = '33';

end foreach

return 0, "Actualizacion Exitosa";

end procedure