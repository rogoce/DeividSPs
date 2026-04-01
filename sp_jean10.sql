
DROP procedure sp_jean10;
CREATE procedure sp_jean10()
RETURNING integer;

DEFINE _centro_costo    CHAR(3);
define _renglon,_valor integer;
define _cuenta char(25);
define _prima_ret dec(16,2);
DEFINE _no_endoso,_no_poliza    CHAR(10);
define _suma          dec(16,2);
define _no_unidad     char(5);
define _cnt     smallint;


let _prima_ret = 0.00;

{let _cod_auxiliar = '05817';
foreach
	select no_requis
	  into _no_requis
	  from chqchmae
	 where origen_cheque = 'F'
	   and fecha_captura = today -1
	
	delete from chqctaux where no_requis = _no_requis;
	
	foreach
		select renglon,
			   cuenta,
			   debito,
			   centro_costo		   
		  into _renglon,
			   _cuenta,
			   _db,
			   _centro_costo
		  from chqchcta
		 where no_requis = _no_requis
		   and cuenta[1,3] = '570'
		 order by cuenta

			insert into	chqctaux(
			no_requis,
			renglon,
			cuenta,
			cod_auxiliar,
			debito,
			credito,
			centro_costo
			)
			values(
			_no_requis,
			_renglon,
			_cuenta,
			_cod_auxiliar,
			_db,
			0,
			_centro_costo
			);
	end foreach
end foreach
}

foreach
	select no_endoso,
	       no_poliza,
		   suma_asegurada
	  into _no_endoso,
           _no_poliza,
           _suma
      from endedmae
	 where actualizado = 1
	   and no_factura in('06-116504','06-116579','01-2829642','07-85803','11-62847')
	   

{'01-2844928','01-2856885','01-2858740','11-62353','07-85147','07-85645','07-85918','10-75258','10-75414','07-86434','10-76971','10-77313','01-2826476',
'01-2861529','01-2876885','05-79849','07-84143','02-112323','07-85313','07-86243','10-75352','10-76082','10-75892','10-76658','01-2827000','01-2830562',
'01-2859718','01-2867607','01-2835086','02-112102','01-2849287','03-224157','01-2857851','01-2835370','01-2857852','01-2857850','01-2833344','01-2867317',
'01-2878764','01-2845622','01-2874535','01-2856730')}

{'01-2833062','01-2800304','01-2864304',
'01-2864303','01-2864305',
'01-2864812','01-2864306','11-62191','01-2833060','01-2875030','01-2829985','02-111763','03-219379','01-2826828','01-2866377','11-62309','03-221119',
'01-2844928','01-2856885','01-2858740','11-62353','07-85147','07-85645','07-85918','10-75258','10-75414','07-86434','10-76971','10-77313','01-2826476',
'01-2861529','01-2876885','05-79849','07-84143','02-112323','07-85313','07-86243','10-75352','10-76082','10-75892','10-76658','01-2827000','01-2830562',
'01-2859718','01-2867607','01-2835086','02-112102','01-2849287','03-224157','01-2857851','01-2835370','01-2857852','01-2857850','01-2833344','01-2867317',
'01-2878764','01-2845622','01-2874535','01-2856730')
}
	select count(*)
	  into _cnt
	  from endeduni
	 where no_poliza = _no_poliza
       and no_endoso = _no_endoso;

	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt = 1 then
	
		select no_unidad into _no_unidad from endeduni
		where no_poliza = _no_poliza
		  and no_endoso = _no_endoso;
		
		let _valor = sp_proe04b_vida(_no_poliza, _no_unidad , _suma, _no_endoso,'00858');
		
		select sum(r.prima)
		  into _prima_ret
		  from emifacon r, reacomae t
		 where r.cod_contrato = t.cod_contrato
		   and r.no_poliza = _no_poliza
		   and r.no_endoso = _no_endoso
		   and t.tipo_contrato = 1;
		   
		update endedmae
           set prima_retenida = _prima_ret
         where no_poliza = _no_poliza
           and no_endoso = _no_endoso;
		   
		update endedhis
           set prima_retenida = _prima_ret
         where no_poliza = _no_poliza
           and no_endoso = _no_endoso;

	end if
	  
end foreach

return 0;

END PROCEDURE;