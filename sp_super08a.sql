   --Hoja F - Factor de Zona Geografica
   --Estadistico para la superintendencia
   --  Armando Moreno M. 11/03/2017
   
   DROP procedure sp_super08a;
   CREATE procedure sp_super08a(a_periodo CHAR(7), a_gobierno smallint default 0)
   RETURNING char(7) as periodo,
             char(50) as ramo,
			 char(20) as poliza,
			 char(50) as forma_pago,
			 decimal(16,2) as monto_recuperado;

   DEFINE _n_ramo  CHAR(50);
   DEFINE _monto_cancelacion,_monto_rehab dec(16,2);
   DEFINE v_desc_ramo,_n_formapag        CHAR(50);
   define _no_documento      char(20);
   define _periodo			 char(7);
    
SET ISOLATION TO DIRTY READ;

let _monto_cancelacion = 0.00;
let _monto_rehab	   = 0.00;
let _no_documento      = '';

foreach
	select t.periodo,
	       r.nombre,
		   e.no_documento,
		   z.nombre,
		   sum(t.monto_rehab)
	  into _periodo,
	       _n_ramo,
		   _no_documento,
		   _n_formapag,
		   _monto_rehab
	  from deivid_cob:tmp_morosidad t, prdramo r, emipomae e, cobforpa z
	 where t.cod_ramo = r.cod_ramo
       and t.no_poliza = e.no_poliza
	   and e.cod_formapag = z.cod_formapag
       and e.actualizado = 1
	   and t.periodo = a_periodo
	   and gobierno = a_gobierno
	   and t.monto_rehab <> 0
    group by 1,2,3,4
    order by 1,2


	return _periodo,_n_ramo,_no_documento,_n_formapag,_monto_rehab with resume;
end foreach

END PROCEDURE;