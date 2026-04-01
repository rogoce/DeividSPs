CREATE OR REPLACE PROCEDURE "TTCORP"."ACTUALIZA_TEMP_TRANSF" (p_tipo_transf NUMBER) IS
BEGIN
   DECLARE
      v_contador_sin         det_movim_tecnico_sin.id_mov_tecnico%TYPE := NULL;
      v_contador_sin_rea     det_movim_reaseguro_sin.id_mov_reas%TYPE := NULL;
      v_contador_pri         det_movim_tecnico_pri.id_mov_tecnico%TYPE := NULL;
      v_contador_pri_rea     det_movim_reaseguro_pri.id_mov_reas%TYPE := NULL;
      v_contador_pri_carac   det_movim_reaseguro_pri.id_mov_reas%TYPE := NULL;
      v_ramo_ttcorp          tmp_ramo_rea.ramo_ttcorp%TYPE;
      v_actualiza_tec        BOOLEAN;
      v_actualiza_rea        BOOLEAN;
      v_actualiza_car        BOOLEAN;
      v_id_cliente           mae_relacionado.id_relacionado%TYPE;
      v_id_productor         mae_relacionado.id_relacionado%TYPE;
      v_id_reaseguradora     mae_relacionado.id_relacionado%TYPE;
      v_id_relacionado       mae_relacionado.id_relacionado%TYPE;  
      v_fin                  VARCHAR2 (100);

      CURSOR c1 IS
         SELECT ROWID row_id
               ,id_mov_tecnico_ancon
               ,cod_ramorea_ancon
               ,cod_ramo_ancon
               ,cod_subramo
         FROM tmp_det_movim_tecnico_sin
         WHERE ind_actualizado = '0'
         ORDER BY ROWID;

      CURSOR c2 (
         pc_id_mov_tecnico_ancon tmp_det_movim_tecnico_sin.id_mov_tecnico_ancon%TYPE) IS
         SELECT ROWID row_id
         FROM tmp_det_movim_reaseguro_sin
         WHERE id_mov_tecnico_ancon = pc_id_mov_tecnico_ancon
         ORDER BY ROWID;

      CURSOR c3 IS
         SELECT ROWID row_id, id_mov_tecnico
         FROM tmp_det_movim_tecnico_sin
         WHERE ind_actualizado = '45'
         ORDER BY ROWID;

      CURSOR c4 (
         pc_id_mov_tecnico tmp_det_movim_tecnico_sin.id_mov_tecnico%TYPE) IS
         SELECT id_mov_reas
         FROM det_movim_reaseguro_sin
         WHERE id_mov_tecnico = pc_id_mov_tecnico
         ORDER BY id_mov_reas;

      CURSOR c5 IS
         SELECT ROWID row_id
               ,id_mov_tecnico_ancon
               ,cod_ramorea_ancon
               ,cod_ramo_ancon
               ,cod_subramo
         FROM tmp_det_movim_tecnico_pri
         WHERE ind_actualizado = '0'
         ORDER BY ROWID;

      CURSOR c6 (
         pc_id_mov_tecnico_ancon tmp_det_movim_tecnico_pri.id_mov_tecnico_ancon%TYPE) IS
         SELECT ROWID row_id, id_mov_reas_ancon, tip_contrato
         FROM tmp_det_movim_reaseguro_pri
         WHERE id_mov_tecnico_ancon = pc_id_mov_tecnico_ancon
         and ind_actualizado = '0'
         ORDER BY ROWID;

      CURSOR c7 IS
         SELECT ROWID row_id
               ,id_mov_tecnico
               ,mto_prima
               ,id_relac_cliente
               ,id_relac_productor
         FROM tmp_det_movim_tecnico_pri
         WHERE ind_actualizado = '1'
         ORDER BY ROWID;

      CURSOR c8 (
         pc_id_mov_tecnico tmp_det_movim_tecnico_pri.id_mov_tecnico%TYPE) IS
         SELECT rowid row_id, id_mov_reas, id_relacionado
         FROM tmp_det_movim_reaseguro_pri
         WHERE id_mov_tecnico = pc_id_mov_tecnico
           and tip_contrato is not null
           and ind_actualizado = '1'
         ORDER BY id_mov_reas;

      CURSOR c9 (pc_id_relac_filial mae_relacionado.id_relac_filial%TYPE) IS
         SELECT id_relacionado
         FROM mae_relacionado
         WHERE id_relac_filial = pc_id_relac_filial;

      CURSOR c10 (
         pc_id_mov_reas tmp_det_reaseguro_caract_pri.id_mov_reas%TYPE) IS
         SELECT rowid row_id, id_reas_caract, id_relacionado
         FROM tmp_det_reaseguro_caract_pri
         WHERE id_mov_reas = pc_id_mov_reas
         and  ind_actualizado = '1'
         ORDER BY id_reas_caract;

      CURSOR c11 (
         pc_id_mov_reas_ancon tmp_det_reaseguro_caract_pri.id_mov_reas_ancon%TYPE) IS
         SELECT id_reas_caract_ancon
         FROM tmp_det_reaseguro_caract_pri
         WHERE id_mov_reas_ancon = pc_id_mov_reas_ancon
         and ind_actualizado = '0'
         ORDER BY id_reas_caract;
         
     CURSOR c12 IS
         SELECT rowid row_id
         FROM tmp_cliente
         WHERE ind_actualizado = '0';  

     CURSOR c13 IS
         SELECT rowid row_id
         FROM tmp_productor
         WHERE ind_actualizado = '0';  

     CURSOR c14 IS
         SELECT rowid row_id
         FROM tmp_reaseguradoras
         WHERE ind_actualizado = '0';  

     CURSOR c15 IS
         SELECT rowid row_id
         FROM tmp_terceros
         WHERE ind_actualizado = '0';  


   BEGIN
      IF p_tipo_transf = 1 THEN
         SELECT NVL (MAX (id_mov_tecnico), 0) + 1
         INTO v_contador_pri
         FROM det_movim_tecnico_pri;

         SELECT NVL (MAX (id_mov_reas), 0) + 1
         INTO v_contador_pri_rea
         FROM det_movim_reaseguro_pri;

         SELECT NVL (MAX (id_reas_caract), 0) + 1
         INTO v_contador_pri_carac
         FROM det_reaseguro_caract_pri;

         IF v_contador_pri IS NOT NULL THEN
            FOR v5 IN c5 LOOP
               BEGIN
                  SELECT ramo_ttcorp
                  INTO v_ramo_ttcorp
                  FROM tmp_ramo_rea
                  WHERE ramo_ancon = v5.cod_ramorea_ancon;

                  UPDATE tmp_det_movim_tecnico_pri
                   SET ind_actualizado = '1'
                      ,id_mov_tecnico = v_contador_pri
                      ,id_relac_productor =
                          'PRO' || LPAD (id_relac_productor_ancon, 5, 0)
                      ,id_relac_cliente =
                          DECODE (
                             LENGTH (id_relac_cliente_ancon)
                            ,6
                            ,'CLI' || id_relac_cliente_ancon
                            ,'CLI' || LPAD (id_relac_cliente_ancon, 5, 0))
                      ,id_certificado =
                          DECODE (NVL (id_certificado, 'X'),
                                  'X', '000001',
                                  id_certificado)
                      ,cod_ramo     = cod_ramo_ancon
                      ,cod_ramorea  = v_ramo_ttcorp
                  WHERE ROWID = v5.row_id;


                  IF v_contador_pri_rea IS NOT NULL
                     AND v_contador_pri_carac IS NOT NULL THEN
                     FOR v6 IN c6 (v5.id_mov_tecnico_ancon) LOOP
                        BEGIN
                        
                           if v6.tip_contrato is null then

                             delete from tmp_det_reaseguro_caract_pri
                                where id_mov_reas_ancon = v6.id_mov_reas_ancon
                                and ind_actualizado = '0';


                             delete from tmp_det_movim_reaseguro_pri
                             where ROWID = v6.row_id;
                             
                           
                           else
                              UPDATE tmp_det_movim_reaseguro_pri
                               SET id_mov_reas  = v_contador_pri_rea
                                  ,id_mov_tecnico = v_contador_pri
                                  ,id_relacionado =
                                      DECODE (
                                         NVL (id_relacionado_ancon, 0)
                                        ,0
                                        ,NULL
                                        ,'CIR'
                                         || LPAD (id_relacionado_ancon, 6, 0))
                                  ,ind_actualizado = '1'      
                              WHERE ROWID = v6.row_id;

                              FOR v11 IN c11 (v6.id_mov_reas_ancon) LOOP
 
                                 UPDATE tmp_det_reaseguro_caract_pri
                                  SET id_reas_caract = v_contador_pri_carac
                                     ,id_mov_reas  = v_contador_pri_rea
                                     ,id_relacionado =
                                        DECODE (
                                            NVL (id_relacionado_ancon, 0)
                                           ,0
                                           ,NULL
                                           ,'CIR'
                                            || LPAD (id_relacionado_ancon, 6, 0))
                                     ,ind_actualizado = '1'
                                 WHERE id_reas_caract_ancon = v11.id_reas_caract_ancon
                                 and   ind_actualizado = '0';

                                 v_contador_pri_carac := v_contador_pri_carac + 1;
                              END LOOP;   
                              v_contador_pri_rea := v_contador_pri_rea + 1; 
                           end if;
                         END;
                     END LOOP;

                     v_contador_pri := v_contador_pri + 1;
                  END IF;
               --               EXCEPTION
               --                  WHEN OTHERS THEN NULL;
               END;

               COMMIT;
            END LOOP;

            SELECT TO_CHAR (SYSDATE, 'hh:mi:ss')
            INTO v_fin
            FROM DUAL;

            
            FOR v7 IN c7 LOOP    --LEO LOS REGISTROS CON IND_ACTUALIZADO = '1'
               BEGIN

                  v_actualiza_tec := TRUE;
                  v_actualiza_rea := TRUE;
                  v_actualiza_car := TRUE;

                  v_id_cliente := NULL;
                  v_id_productor := NULL;

                  BEGIN
                     IF v7.id_relac_cliente IS NOT NULL THEN
                        FOR v40 IN c9 (v7.id_relac_cliente) LOOP
                           v_id_cliente := v40.id_relacionado;
                        END LOOP;

                        IF v_id_cliente IS NULL THEN
                        DBMS_OUTPUT.put_line ('No hay cliente ' ||v7.id_relac_cliente );
                           v_actualiza_tec := FALSE;
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                     DBMS_OUTPUT.put_line ('wo cliente ' ||v7.id_relac_cliente||'-'||sqlerrm );
                        v_actualiza_tec := FALSE;
                  END;

                  BEGIN
                     IF v7.id_relac_productor IS NOT NULL THEN
                        FOR v41 IN c9 (v7.id_relac_productor) LOOP
                           v_id_productor := v41.id_relacionado;
                        END LOOP;

                        IF v_id_productor IS NULL THEN
                           DBMS_OUTPUT.put_line ('No hay productor ' ||v7.id_relac_productor );
                           v_actualiza_tec := FALSE;
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        DBMS_OUTPUT.put_line ('wo productor ' ||v7.id_relac_cliente||'-'||sqlerrm );
                        v_actualiza_tec := FALSE;
                  END;


                  IF v_actualiza_tec THEN
                     BEGIN
                        INSERT INTO det_movim_tecnico_pri
                           SELECT id_mov_tecnico
                                 ,cod_empresa
                                 ,num_ano
                                 ,num_mes
                                 ,num_serie
                                 ,cod_area_seguro
                                 ,cod_producto
                                 ,cod_ramo
                                 ,cod_ramorea
                                 ,cod_moneda
                                 ,por_tasa
                                 ,tip_poliza
                                 ,id_poliza
                                 ,id_recibo
                                 ,id_certificado
                                 ,fec_inivig
                                 ,fec_finvig
                                 ,fec_emision
                                 ,a.cod_situacion
                                 ,a.fec_situacion
                                 ,mto_suma
                                 ,mto_reserva
                                 ,NVL (mto_prima, 0)
                                 ,NVL (mto_comision, 0)
                                 ,v_id_cliente
                                 ,v_id_productor
                                 ,a.fec_operacion
                                 ,a.fec_registro
                                 ,a.cod_usuario
                                 ,''
                                 ,a.nro_remosa
                                 ,a.renglon
                                 ,a.cod_sucursal
                                 ,a.tipo_produccion
                                 ,a.tipo_impuesto
                                 ,a.cod_subramo
                                 ,a.ind_colectivo
                                 ,a.nueva_renovacion
                           FROM tmp_det_movim_tecnico_pri a
                           WHERE a.rowid = v7.row_id;
                        DBMS_OUTPUT.put_line ('inserto ');
                        v_actualiza_tec := TRUE;
                     EXCEPTION
                        WHEN OTHERS THEN
                           DBMS_OUTPUT.put_line ('error al insertar ' ||sqlerrm );
                           v_actualiza_tec := FALSE;
                     END;

                     FOR v8 IN c8 (v7.id_mov_tecnico) LOOP --LEO EL RESEGURO_PRI POR EL ID_MOV_TECNICO
                     DBMS_OUTPUT.put_line ('error al for 8' ||sqlerrm );
                        v_id_reaseguradora := NULL;
                        BEGIN
                           IF v8.id_relacionado IS NOT NULL THEN
                              FOR v42 IN c9 (v8.id_relacionado) LOOP
                                 v_id_reaseguradora := v42.id_relacionado;
                              END LOOP;

                              IF v_id_reaseguradora IS NULL THEN
                              DBMS_OUTPUT.put_line ('no hay reaseguradora ' ||v8.id_relacionado );
                                 v_actualiza_rea := FALSE;
                                 EXIT;
                              END IF;
                           END IF;
                        EXCEPTION
                           WHEN OTHERS THEN
                           DBMS_OUTPUT.put_line ('nwo reaseguradora ' ||v8.id_relacionado );
                              v_actualiza_rea := FALSE;
                              EXIT;
                        END;

                        IF v_actualiza_rea then
                           BEGIN
DBMS_OUTPUT.put_line ('error al insertar reaseguro ' ||sqlerrm );
                              INSERT INTO det_movim_reaseguro_pri
                                 SELECT id_mov_reas
                                       ,tip_contrato
                                       ,por_part_total
                                       ,por_part_reaseg
                                       ,a.id_mov_tecnico
                                       ,SYSDATE fec_operacion
                                       ,SYSDATE fec_registro
                                       ,'TTCORP' cod_usuario
                                       ,v_id_reaseguradora
                                 FROM tmp_det_movim_reaseguro_pri a
                                 WHERE a.rowid = v8.row_id;
                              
                              update tmp_det_movim_reaseguro_pri 
                                 set ind_actualizado = '2'
                                 WHERE rowid = v8.row_id;
                                      
                              v_actualiza_rea := TRUE;
                           EXCEPTION
                              WHEN OTHERS THEN
                              DBMS_OUTPUT.put_line ('error al insertar rease' ||sqlerrm );
                                 v_actualiza_rea := FALSE;
                                 EXIT;
                           END;
                        end if;   
                        
                        

                        FOR v10 IN c10 (v8.id_mov_reas) LOOP
                           v_id_reaseguradora := NULL;

                           BEGIN
                              IF v10.id_relacionado IS NOT NULL THEN
                                 FOR v43 IN c9 (v10.id_relacionado) LOOP
                                    v_id_reaseguradora := v43.id_relacionado;
                                 END LOOP;

                                 IF v_id_reaseguradora IS NULL THEN
                                 DBMS_OUTPUT.put_line ('no hay reaseguradora ' ||sqlerrm );
                                    v_actualiza_car := FALSE;
                                    EXIT;
                                 END IF;
                              END IF;
                           EXCEPTION
                              WHEN OTHERS THEN
                              DBMS_OUTPUT.put_line ('wo reaseguradora ' ||sqlerrm );
                                 v_actualiza_car := FALSE;
                                 EXIT;
                           END;

                           
                           if v_actualiza_car then
                              BEGIN
                                 INSERT INTO det_reaseguro_caract_pri
                                    SELECT id_reas_caract
                                          ,tip_contrato
                                          ,cod_concepto
                                          ,mto_concepto
                                          ,id_mov_reas
                                          ,fec_operacion
                                          ,fec_registro
                                          ,cod_usuario
                                          ,v_id_reaseguradora
                                          ,DECODE (
                                              v7.mto_prima
                                             ,0
                                             ,0
                                             , round((mto_concepto * 100)
                                              / v7.mto_prima),6)
                                    FROM tmp_det_reaseguro_caract_pri a
                                    WHERE a.rowid =v10.row_id;
                                                
                                 update tmp_det_reaseguro_caract_pri
                                    set ind_actualizado = '2'
                                  WHERE rowid =v10.row_id;
                                                   
                                                
                              EXCEPTION
                                 WHEN OTHERS THEN
                                 DBMS_OUTPUT.put_line ('wo caracateristica ' ||sqlerrm );
                                    v_actualiza_car := FALSE;
                                    EXIT;
                              END;
                           end if;

                        END LOOP; --FIN DEL FOR 10 (CARACT_PRI POR ID_MOV_REAS)

                        IF NOT (v_actualiza_car) THEN
                           v_actualiza_rea := FALSE;
                           EXIT;
                        END IF;
                     END LOOP; --FIN DEL FOR 8 (REASEGURO_PRI POR ID_MOV_TECNICO
                  END IF;
               END;
               
               if not(v_actualiza_tec ) then
                  DBMS_OUTPUT.put_line ('not tec ' ||v7.row_id );
                  end if;
                  
                if not(v_actualiza_rea ) then
                  DBMS_OUTPUT.put_line ('not rea ' ||v7.row_id );
                  end if;
                  
                   if not(v_actualiza_car ) then
                  DBMS_OUTPUT.put_line ('not car ' ||v7.row_id );
                  end if;
                  

               IF v_actualiza_tec AND v_actualiza_rea AND v_actualiza_car THEN
                  UPDATE tmp_det_movim_tecnico_pri
                   SET ind_actualizado = '2'
                  WHERE ROWID = v7.row_id;
                  COMMIT;
               ELSE
                  ROLLBACK;
               END IF;
            END LOOP;
         END IF;
      ELSIF p_tipo_transf = 2 THEN
         null;
      elsIF p_tipo_transf = 3 THEN
         begin
            SELECT MAX (id_relacionado) + 1
                  INTO v_id_relacionado
            FROM mae_relacionado;
         
            if v_id_relacionado is not null then
                  for v12 in c12 loop
                      begin
                         insert into mae_relacionado
                         select v_id_relacionado,
                                0,
                                99999,
                                0,
                                substr(cedula,1,25),
                                nombre_razon,
                                nombre,
                                to_date('28/11/2000','dd/mm/yyyy'),
                                1,
                                trunc(sysDATE),
                                ltrim(rtrim('CLI'||COD_CLIENTE))
                           from tmp_cliente
                          where rowid = v12.row_id;
               
                          update tmp_cliente set ind_actualizado = 2,
                                                 id_relacionado = v_id_relacionado
                           where rowid = v12.row_id;
                          commit;
                          v_id_relacionado := v_id_relacionado + 1;

                      exception
                         when others then 
                         DBMS_OUTPUT.put_line ('3' ||sqlerrm );
                            rollback;
                      end;      
                  end loop;          
            end if;
            
         exception
            when others then
                 DBMS_OUTPUT.put_line ('3 ' ||sqlerrm );
               rollback;   

         end;
      elsIF p_tipo_transf = 4 THEN
         begin
            SELECT MAX (id_relacionado) + 1
                  INTO v_id_relacionado
            FROM mae_relacionado;
         
            if v_id_relacionado is not null then
                  for v13 in c13 loop
                      begin
                         insert into mae_relacionado
                         select v_id_relacionado,
                                0,
                                99999,
                                0,
                                substr(cedula,1,25),
                                nombre nombre_razon,
                                nombre,
                                to_date('28/11/2000','dd/mm/yyyy'),
                                1,
                                trunc(sysDATE),
                                ltrim(rtrim('PRO'||lpad(COD_agente,5,'0')))
                          from  tmp_productor
                          where rowid = v13.row_id;
               
                          update tmp_productor set ind_actualizado = 2,
                                                   id_relacionado = v_id_relacionado
                           where rowid = v13.row_id;
                          commit;
                          v_id_relacionado := v_id_relacionado + 1;

                      exception
                         when others then 
                         DBMS_OUTPUT.put_line ('3' ||sqlerrm );
                            rollback;
                      end;      
                  end loop;          
            end if;
            
         exception
            when others then
                 DBMS_OUTPUT.put_line ('1 ' ||sqlerrm );
               rollback;   

         end;
      elsIF p_tipo_transf = 5 THEN
         begin
            SELECT MAX (id_relacionado) + 1
                  INTO v_id_relacionado
            FROM mae_relacionado;
         
            if v_id_relacionado is not null then
                  for v14 in c14 loop
                      begin
                         insert into mae_relacionado
                         select v_id_relacionado,
                                0,
                                99999,
                                0,
                                ltrim(rtrim('CIR'||lpad(COD_COASEGUR,6,'0'))),
                                nombre nombre_razon,
                                NULL,
                                to_date('01/06/2020','dd/mm/yyyy'),
                                1,
                                to_date('01/06/2020','dd/mm/yyyy'),
                                ltrim(rtrim('CIR'||lpad(COD_COASEGUR,6,'0')))
                          from  tmp_reaseguradoras
                          where rowid = v14.row_id;
               
                          update tmp_reaseguradoras set ind_actualizado = 2
                           where rowid = v14.row_id;
                          commit;
                          v_id_relacionado := v_id_relacionado + 1;

                      exception
                         when others then 
                         DBMS_OUTPUT.put_line ('5' ||sqlerrm );
                            rollback;
                      end;      
                  end loop;
            END IF;         
         exception
            when others then
                 DBMS_OUTPUT.put_line ('5 ' ||sqlerrm );
               rollback;   

         end;
      elsIF p_tipo_transf = 6 THEN
         begin
            SELECT MAX (id_relacionado) + 1
                  INTO v_id_relacionado
            FROM mae_relacionado;
         
            if v_id_relacionado is not null then
                  for v15 in c15 loop
                      begin
                         insert into mae_relacionado
                         select v_id_relacionado,
                                0,
                                99999,
                                0,
                                ltrim(rtrim('TER'||lpad(TER_CODIGO,5,'0'))),
                                ter_descripcion nombre_razon,
                                NULL,
                                to_date('31/12/1899','dd/mm/yyyy'),
                                1,
                                to_date('31/12/1899','dd/mm/yyyy'),
                                ltrim(rtrim('TER'||lpad(TER_CODIGO,5,'0')))
                          from  tmp_TERCEROS
                          where rowid = v15.row_id;
               
                          update tmp_TERCEROS set ind_actualizado = 2
                           where rowid = v15.row_id;
                          commit;
                          v_id_relacionado := v_id_relacionado + 1;

                      exception
                         when others then 
                         DBMS_OUTPUT.put_line ('6' ||sqlerrm );
                            rollback;
                      end;      
                  end loop;          
            end if;
            
         exception
            when others then
                 DBMS_OUTPUT.put_line ('6 ' ||sqlerrm );
               rollback;   

         end;
      END IF;
   END;
END actualiza_temp_transf; 